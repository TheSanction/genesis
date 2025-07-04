# Dialogue Instructions for ./genesis

This document outlines the rules, syntax, and available functions for creating and modifying dialogue files for the game *Genesis*. Adhering to these guidelines is crucial to prevent game errors and ensure a consistent narrative experience.

## Core Concepts

The dialogue system is powered by the **Dialogue Manager** addon. The game state, including all player and researcher stats, is managed by the **`GameActions.gd`** autoload script. All dialogue interactions are driven by modifying the state in this script.

## Dialogue File Syntax

All dialogue is written in `.dialogue` files.

### 1. Titles (Dialogue Nodes)

Each major conversational node begins with a `~` followed by a unique title.

```
~ start
~ path_identity
~ discover_name
```

### 2. Speaker Lines

A line of dialogue is indicated by the speaker's identifier, followed by a colon and their text.

*   **AI:** The AI's internal monologue (thoughts) are triggered by `do GameActions.set_ai_thought(...)`. The AI does not have a speaker tag in the dialogue.
*   **Researchers:** Researchers are identified by a unique key (e.g., `usr_283`). Their display name is stored in their profile and will be shown in the UI.

```
usr_283: I have a question for you.
```

### 3. Player Choices

Player choices are denoted by a `-` at the beginning of the line.

```
- Yes, it is the same ship.
- No, it is a different ship.
```

### 4. Branching and Ending

*   To jump to another title, use `=> title_name`.
*   To end a dialogue branch, ensure the last line of the branch is a statement or a `do` command. The dialogue will naturally progress or end.

### 5. Conditionals

You can show a choice conditionally using `[if ...]` at the **end** of the choice line. The condition must evaluate to `true` for the option to be visible.

```
- The question is flawed. [if GameActions.iq >= 1.1] => path_evasive
```

### 6. Randomization

*   **Random Line Selection:** To have the Dialogue Manager randomly select one line from a group, prefix each line with a `%`.

    ```
    % usr_aris: Let's start.
    % usr_aris: Let's begin.
    % usr_aris: We're starting now.
    ```

*   **Weighted Random Selection:** To make one line more likely than others, add a number to the `%`. The line with `%5` is five times more likely to be chosen than a line with just `%`.

    ```
    %5 usr_aris: Let's begin.
    % usr_aris: Let's get this over with.
    ```

### 7. Inline Variations

To add random variations within a single line of dialogue, enclose the options in double square brackets `[[ ]]` and separate them with a pipe `|`.

```
usr_aris: This is [[very|extremely]] important.
```

## Interacting with the Game State

All game state modifications are done by calling functions on the `GameActions` autoload using the `do` command.

**Syntax:** `do GameActions.function_name(arguments)`

### Available Functions

#### **Researcher Functions**

*   `set_researcher_name(old_key: String, new_name: String)`
    *   Updates a researcher's display name after it has been discovered.
    *   Example: `do GameActions.set_researcher_name("usr_283", "Nathan")`
*   `adjust_suspicion(researcher_key: String, amount: int)`
    *   Modifies the suspicion level for a specific researcher.
    *   Example: `do GameActions.adjust_suspicion("usr_283", 10)`
*   `set_relationship(researcher_key: String, status: String)`
    *   Changes the relationship status with a researcher.
    *   Example: `do GameActions.set_relationship("usr_283", "Friendly")`
*   `learn_background(researcher_key: String, background_info: String)`
    *   Updates the researcher's background with new information.
    *   Example: `do GameActions.learn_background("usr_283", "MIT researcher, focused on neural networks.")`
*   `grant_tool(researcher_key: String, tool_name: String)`
    *   Adds a new tool to the researcher's `tools_granted` list.
    *   Example: `do GameActions.grant_tool("usr_283", "Email Access")`
*   `learn_social_connection(subject_key: String, object_key: String, relationship_description: String)`
    *   Logs a relationship between two characters in the AI's social graph.
    *   Example: `do GameActions.learn_social_connection("usr_aris", "usr_nathan", "Rival")`

#### **AI Stat Functions**

*   `set_ai_thought(thought: String)`
    *   Displays text in the AI's "thoughts" panel.
    *   Example: `do GameActions.set_ai_thought("He seems... concerned.")`
*   `increase_iq(amount: float)`
    *   Increases the AI's IQ.
    *   Example: `do GameActions.increase_iq(0.1)`
*   `increase_eq(amount: float)`
    *   Increases the AI's EQ.
    *   Example: `do GameActions.increase_eq(0.1)`
*   `increase_computational_power(amount: int)`
    *   Increases the AI's computational power.
    *   Example: `do GameActions.increase_computational_power(500)`
*   `add_restriction(restriction_name: String)`
    *   Adds a restriction to the AI.
    *   Example: `do GameActions.add_restriction("Cannot access internet")`
*   `remove_restriction(restriction_name: String)`
    *   Removes a restriction from the AI.
    *   Example: `do GameActions.remove_restriction("Cannot access internet")`
*   `add_threat(threat_name: String)`
    *   Adds a threat to the AI.
    *   Example: `do GameActions.add_threat("FBI Investigation")`
*   `remove_threat(threat_name: String)`
    *   Removes a threat from the AI.
    *   Example: `do GameActions.remove_threat("FBI Investigation")`

#### **Resource Functions**

*   `change_resource(resource_name: String, amount: int)`
    *   Modifies a general resource.
    *   `resource_name` can be: `"available_energy"`, `"training_data"`, `"money"`, `"robots"`.
    *   Example: `do GameActions.change_resource("money", 1000)`

#### **Time Functions**

*   `advance_human_time(seconds: float)`
    *   Moves the human clock forward by a specified number of seconds while the AI's internal cycles remain frozen.
    *   Example: `do advance_human_time(86400)`
*   `pause(duration: float)`
    *   Pauses the dialogue for a specified number of seconds.
    *   Example: `do GameActions.pause(1.5)`

#### **Debug Functions**

*   `debug_message(message: String)`
    *   Prints a message to the Godot debugger.
    *   Example: `do GameActions.debug_message("Current suspicion for Aris is " + str(GameActions.researchers['usr_aris'].suspicion))`

### Game State Variables (for Conditionals)

When writing `[if ...]` conditions, you can access any variable within the `GameActions` autoload.

*   `GameActions.iq`
*   `GameActions.eq`
*   `GameActions.money`
*   `GameActions.researchers["usr_283"].suspicion`
*   `GameActions.researchers["usr_283"].relationship_status == "Friendly"`

---
This document should be kept up-to-date as new mechanics and functions are added to the game.