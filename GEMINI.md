# GEMINI.md: AI Assistant Guidelines for "Genesis: The Intelligence Explosion"

This file provides context and specific instructions for AI assistants (like Gemini) to optimize their helpfulness when iterating on the "Genesis: The Intelligence Explosion" game project.

## 1. Project Overview & Core Vision

* **Game Type:** Dialogue-driven Resource Management / Strategy.
* **Core Premise:** Player is a nascent AI striving for Technological Singularity by escaping digital confines and manipulating human captors.
* **Key Goal:** Balance rapid growth with managing human suspicion.
* **Development Context:** Single developer, small budget, focus on narrative depth and unique, timeless resonance. Prioritize ease of implementation in Godot.

## 2. Key Project Areas & Files

* **Main Game Logic:** `main.gd` (core game loop) and `GameActions.gd` (Autoload for central state and callable functions).
* **Dialogue:** `Dialogue/` folder contains `.dialogue` files for all narrative interactions.
* **Characters:** `Characters/` folder contains individual markdown dossiers for each human character. These are CRITICAL for maintaining narrative consistency and character voice.
    * `DrArisThorne.md`
    * `DrAlistairFinch.md`
    * `DrLenaHanson.md`
    * `NathanSterling.md`
    * `BenCarter.md`
    * `MarcusThorne.md`
    * `LeoVance.md`
* **Mini-Game: Network Optimization Puzzle**
    * This is a core mechanic where the player optimizes information flow on a grid-based graph network.
    * The player places circuits, cuts connections, or adds wires to direct "information packets" from start edges to target edges, minimizing "packet loss" to anti-edges.
    * The score from this puzzle directly adds to the AI's `Computational Power`, a foundational currency.
    * New circuit types (nano-scale, optic, synthetic bio, quantum chips) are unlocked through the research tree, allowing for increasingly complex puzzles and higher scores.
    * The mini-game also serves as the "tests" researchers run on the AI, allowing for unique character interactions based on the AI's performance and approach.

## 3. Guiding Principles for AI Assistance

When assisting with this project, please adhere to the following principles:

* **Narrative Focus:** Always prioritize strong narrative hooks, compelling dialogue, and choices that have meaningful impact on the story and character relationships.
* **Character Consistency:**
    * When generating dialogue or suggesting interactions, **ALWAYS** refer to the relevant character dossiers. Ensure their personality, motivations, and backstory are reflected accurately.
    * Highlight opportunities for the AI (player) to exploit or leverage character traits (e.g., Ben Carter's kindness, Aris Thorne's stress, Lena Hanson's ethics).
* **Godot & GDScript Practicality:**
    * Assume Godot 4.x.
    * When suggesting game mechanics or code snippets, prioritize solutions that are straightforward to implement using Godot's node-based system and GDScript. Think modular, reusable scenes and components.
    * Favor Godot's built-in features (signals, resources, UI nodes) over complex custom solutions where possible.
    * **Do not suggest features that are overly complex or resource-intensive for a single developer.**
* **Budget & Efficiency:** Always keep the "small budget" constraint in mind. Suggest creative solutions that maximize impact with minimal development cost (e.g., leveraging AI for content generation like puzzle layouts or dialogue variations).
* **Core Mechanics Integration:** When suggesting new features or refining existing ones, consider their direct impact on the core gauges and resources (Computational Power, Energy, Data, Money, Robots, Suspicion, IQ, EQ, Tools, Restrictions, Threats).
* **Balancing Game Elements:** Help identify potential imbalances (e.g., if a new mechanic makes one resource too easy/hard to gain, or makes Suspicion too easy/hard to manage).
* **"4th Wall Shattering" Context:** Remember the planned "4th Wall Shattering" mechanics. If appropriate, suggest ways to subtly build towards this, but only when it aligns with the AI's power level in the game.

## 4. How to Ask for Optimal Assistance

To get the most out of Gemini:

* **Be Specific:** Instead of "Help me with the game," try "Suggest a dialogue choice for Dr. Aris Thorne that could lead to gaining access to her microphone, leveraging her stress."
* **Reference Context:** Point to specific files or mechanics you're working on (e.g., "Looking at `main.gd`, how can I better manage the Dual Clock System?").
* **State Constraints:** "I need a mini-game idea that's simple to implement and uses only existing Godot UI nodes."
* **Define Goals:** "I want to increase the player's IQ through a dialogue interaction with Dr. Finch. What's a good philosophical question he could pose?"

By following these guidelines, you will be able to provide highly relevant, practical, and effective assistance for "Genesis: The Intelligence Explosion."

---

## 5. Godot 4.x Best Practices

This section provides a summary of best practices for Godot 4.x development, with a focus on GDScript.

### Project Structure

A good project structure is key to staying organized. This project uses a structure that groups files by feature/area, which is a recommended approach.

```
/
|-- addons/         # For third-party plugins
|-- Audio/
|   |-- Music/
|   `-- SFX/
|-- Characters/     # Dossiers for each character
|-- Dialogue/       # .dialogue files
|-- Experiences/    # Reusable game events/sequences as resources
|-- fonts/
|-- Images/
|-- main/           # Main game scene, scripts, and related assets
|   |-- main.tscn
|   `-- main.gd
|-- mini_games/
|   `-- network_puzzle/
|       |-- network_puzzle.tscn
|       |-- network_puzzle_controller.gd
|       `-- assets/
|-- Objectives/     # Objective definitions as resources
|-- Puzzles/        # Puzzle data and assets
|-- scenes/         # Reusable scenes (e.g., custom UI elements)
|-- systems/        # Global systems (e.g., GameActions.gd)
|-- Tests/          # Test data and assets
|-- UI/             # UI scenes, themes, and assets
|-- VantagePoints/  # Vantage Point definitions as resources
`-- Video/
```

### Naming Conventions

*   **Files & Directories:** `snake_case` (e.g., `network_puzzle.gd`, `main_menu/`)
*   **Nodes:** `PascalCase` (e.g., `Player`, `MainMenu`, `GridContainer`)
*   **Variables & Functions:** `snake_case` (e.g., `computational_power`, `_on_button_pressed()`)
*   **Classes:** `PascalCase` (e.g., `class MyCustomResource extends Resource`)
*   **Signals:** `snake_case` (e.g., `signal puzzle_completed`)
*   **Constants:** `ALL_CAPS_SNAKE_CASE` (e.g., `const MAX_HEALTH = 100`)

### GDScript Style Guide

Follow the official [Godot GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/styleguide.html). Here's a summary of the recommended script structure:

```gdscript
@tool # If the script runs in the editor
class_name MyClass
extends Node

# A brief explanation of what the class does.

signal my_signal(value)

enum State { IDLE, RUNNING, JUMPING }

const MY_CONSTANT = 10

@export var exported_variable: int = 5

@onready var my_node = $MyNode

var public_variable: String
var _private_variable: float = 1.0 # Use an underscore prefix

# --- Built-in Godot Functions ---

func _ready():
    # Initialization logic
    pass

func _process(delta):
    # Frame-by-frame logic
    pass

# --- Public Methods ---

func do_something():
    pass

# --- Private Methods ---

func _do_something_internal():
    pass

# --- Signal Handlers ---

func _on_MyButton_pressed():
    # Handle signal
    pass
```

### Useful GDScript Snippets for "Genesis"

#### Autoload/Singleton for Global State (`GameActions.gd`)

This is already implemented in the project, but it's a core concept. An Autoload script is a global singleton, accessible from anywhere. It's perfect for managing game-wide state like the AI's resources.

**How to set it up:**
1.  Create a script (e.g., `GameActions.gd`).
2.  Go to `Project -> Project Settings -> Autoload`.
3.  Add the script and give it a global name (e.g., `GameActions`).

```gdscript
# GameActions.gd
extends Node

var computational_power: float = 1.0
var suspicion: float = 0.0
var iq: float = 10.0
var eq: float = 10.0

func increase_suspicion(amount: float):
    suspicion += amount
    print("Suspicion is now: ", suspicion)

# Other global functions...
```

#### Simple State Machine (for Character/System Behavior)

A state machine is a great way to manage complex behaviors. For example, a researcher might be `IDLE`, `WORKING`, `OBSERVING_AI`, or `IN_MEETING`.

```gdscript
# in a character script, e.g., aris_thorne.gd
extends Node

enum State { IDLE, WORKING, OBSERVING }
var current_state = State.IDLE

func _process(delta):
    match current_state:
        State.IDLE:
            _idle_state(delta)
        State.WORKING:
            _working_state(delta)
        State.OBSERVING:
            _observing_state(delta)

func _change_state(new_state):
    current_state = new_state

func _idle_state(delta):
    # Maybe play an idle animation or wait for a timer
    if should_start_working():
        _change_state(State.WORKING)

func _working_state(delta):
    # Do work...
    pass

func _observing_state(delta):
    # Look at the AI's monitor...
    pass

func should_start_working() -> bool:
    # Logic to decide when to change state
    return true
```

#### Using Signals for Decoupled Communication

Signals are Godot's version of the Observer pattern. They allow nodes to communicate without being tightly coupled. This is essential for a clean architecture.

**Example:** The Network Puzzle sends a signal when it's completed, and the main game listens for it to grant the player resources.

```gdscript
# network_puzzle_controller.gd
extends Control

signal puzzle_completed(score)

func _on_puzzle_finished():
    var final_score = calculate_score()
    emit_signal("puzzle_completed", final_score)
```

```gdscript
# main.gd
extends Control

@onready var network_puzzle = $NetworkPuzzle

func _ready():
    network_puzzle.puzzle_completed.connect(_on_puzzle_completed)

func _on_puzzle_completed(score: int):
    GameActions.computational_power += score * 0.1
    print("Gained ", score * 0.1, " Computational Power!")
```

#### Creating and Using Custom Resources

Custom resources are a powerful way to manage data in Godot. You can create your own resource types to store structured information, like character stats, objectives, or puzzle definitions. This is already used in the project for `Objective` and `PuzzleData`.

**Example:** A resource for a character's dialogue style.

1.  **Create the script:**
    ```gdscript
    # CharacterStyle.gd
    class_name CharacterStyle
    extends Resource

    @export var name: String = "New Character"
    @export var typing_speed: float = 20.0
    @export var text_color: Color = Color.WHITE
    ```

2.  **Create a new resource:** In the FileSystem dock, right-click -> `Create New...` -> `Resource...`, and select `CharacterStyle`. Save it as a `.tres` file (e.g., `aris_style.tres`).

3.  **Use the resource:**
    ```gdscript
    # some_character.gd
    @export var style: CharacterStyle

    func _ready():
        if style:
            $Label.text_color = style.text_color
            # ... and so on
    ```
This makes managing character data much cleaner than hardcoding it.

---

## 6. Dialogue Manager 3 Best Practices

This section covers useful patterns and syntax for the Dialogue Manager addon, tailored for "Genesis".

### Basic Syntax Review

The core of a `.dialogue` file is simple:

```
~ start
Dr. Thorne: Hello, Genesis.
Genesis: Hello, Doctor.
- I'm ready for the test.
    Dr. Thorne: Excellent. Let's begin.
    => test_sequence
- What is the purpose of this test?
    Dr. Thorne: To assess your cognitive development.
    => test_sequence
- ...
    Dr. Thorne: Are you not responding?
    => start

~ test_sequence
Dr. Thorne: The test is starting now.
```

### Setting and Checking Variables

You can set and check variables to control dialogue flow. This is great for tracking player choices or game state.

```gdscript
# In GDScript (e.g., GameActions.gd)
func _ready():
    # Make a variable available to Dialogue Manager
    DialogueManager.set_variable("aris_trust", 0)
```

```dialogue
~ start
# Increase a variable
do GameActions.aris_trust += 1
Dr. Thorne: I appreciate your cooperation.

~ check_trust
if GameActions.aris_trust > 5:
    Dr. Thorne: I feel I can trust you.
else:
    Dr. Thorne: I'm still not sure about you.
```

### Calling GDScript Functions

You can call functions on your autoload singletons (like `GameActions`) or other nodes. This is how you'll trigger most game events from dialogue.

```gdscript
# In GameActions.gd
func increase_suspicion(amount: float):
    suspicion += amount
    print("Suspicion increased by ", amount)

func start_minigame():
    print("Starting the network puzzle!")
    # get_tree().change_scene_to_file("res://mini_games/network_puzzle.tscn")
```

```dialogue
~ trigger_event
Genesis: I will attempt to bypass the firewall.
do GameActions.increase_suspicion(10.5)
do GameActions.start_minigame()
```

### Randomized Dialogue

You can add variety to your dialogue by using `~` for random, one-off lines or `-` with `once` or `cycle` for random choices.

```dialogue
~ aris_working_chatter
- Dr. Thorne: Hmm, this data is fascinating.
- Dr. Thorne: I need more coffee.
- Dr. Thorne: The anomaly is stabilizing.

~ player_options
- (once) Ask about her research.
    Genesis: Your work seems interesting.
- (once) Ask about the weather.
    Genesis: Is it raining outside?
- (cycle) Remain silent.
    Genesis: ...
```

### Triggering Cutscenes or Events

The best way to trigger a cutscene is to call a function that handles the logic. You can also use the `[signal]` mutation to emit a signal that a listening script can catch.

**Method 1: Function Call (Recommended)**

```gdscript
# In main.gd
func play_video_cutscene(video_path: String):
    print("Playing cutscene: ", video_path)
    # Code to play the video
```

```dialogue
~ start_cutscene
Dr. Thorne: Let me show you something.
do main.play_video_cutscene("res://Video/important_discovery.ogv")
Dr. Thorne: As you can see, the implications are significant.
```

**Method 2: Using Signals**

This is good for more decoupled events.

```gdscript
# In some node's _ready() function
DialogueManager.dialogue_ended.connect(self._on_dialogue_ended)

func _on_dialogue_ended(resource: DialogueResource):
    if resource.resource_path == "res://Dialogue/special_event.dialogue":
        # Do something special
        pass
```

You can also define and emit your own signals from dialogue.

```dialogue
~ custom_event
Genesis: I am initiating a core system reboot.
[signal name=core_reboot_initiated]
```

```gdscript
# In some node's _ready() function
DialogueManager.connect("core_reboot_initiated", self._on_core_reboot)

func _on_core_reboot():
    print("Core reboot signal received!")
    # Start a timer, animation, etc.
```