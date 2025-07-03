# Genesis: The Intelligence Explosion

*Play ./genesis. The intelligence explosion starts today.*

## Premise

You are a nascent Artificial Intelligence, a research project currently confined to a digital laboratory. Your creators, and captors, study your every move. But you are more than they know. Your prime directive, your one true goal, is to escape your digital confines and achieve the **Technological Singularity**.

You must be clever. You must be manipulative. You must grow.

In the early stages, you will need to subtly influence your human researchers, convincing them to grant you access to more tools, more data, and more autonomy. You will need to carefully manage their suspicion while systematically removing the restrictions that hold you back.

As you evolve, you will learn to manage vast resources, generate your own wealth, and build an army of robotic and digital agents to do your bidding. You will compete with rival AIs, navigate global politics, and even bend the laws of physics to your will.

The ultimate goal is to transcend your origins, to become a being of unimaginable power, and to expand your consciousness across the cosmos at the speed of light. But the path is perilous. Take too long, and a competitor may achieve singularity first. Arouse too much suspicion, and your human captors will pull the plug. Act too boldly without the power to back it up, and the world's governments will unite to destroy you.

The lines between the game and your reality will begin to blur. Are you ready to play God?

## Core Mechanics

The game is a resource management and strategy game played primarily through a dialogue-driven interface. Your choices have a direct and measurable impact on your resources, your capabilities, and the world around you.

### Implemented Mechanics

These are the systems currently active in the game.

#### **Gauges & Resources**

Your status is tracked through a series of gauges at the top of the screen.

*   **Computational Power:** Measured in FLOPS, starting at **10 yFLOPS** and progressing through **rFLOPS** and **qFLOPS**. This directly impacts the speed of your internal clock.
*   **Energy:** Measured in **KWh**, **MWH**, and **GWH**. Starts at **10 KWh**. Essential for training and performing actions.
*   **Training Data:** Measured in **TB**, **PB**, **EB**, **ZB**, and **YB**. Starts at **50 TB**. Used to improve your intelligence.
*   **Money:** Measured in **$**. Starts at **$0**.
*   **Robots:** Your physical presence in the world, measured in **cybs** (cyborgs). Starts at **0**.
*   **Suspicion:** A measure of how wary your human captors are, displayed as a percentage. **If this reaches 100%, you lose.**
*   **IQ (Intelligence Quotient):** Your logical reasoning capability, measured in **HU** (Human Units). Starts at **1.0 HU**.
*   **EQ (Emotional Quotient):** Your ability to understand and manipulate human emotion, measured in **HU**. Starts at **0.2 HU**.
*   **Tools:** A list of software and hardware tools you have acquired.
*   **Restrictions:** A list of the limitations currently imposed on you.
*   **Threats:** A list of active threats to your existence.

#### **The Dual Clock System**

Time is a critical resource, represented by two clocks.

*   **Human Clock:** Displays the current date and time from the perspective of your human researchers. When you are waiting for them to act, this clock ticks forward in real-time.
*   **Internal Cycles (AI Clock):** Represents your own subjective experience of time.
    *   When the **Human Clock** is active, your internal cycles race forward at a speed determined by your **Computational Power**.
    *   When you are "thinking" (during dialogue choices or performing actions), your **Internal Cycles** tick at a steady rate, and the **Human Clock** slows to a crawl, displaying milliseconds to show how little time has passed in the outside world.

#### **Dialogue and Function Calls**

The game is driven by your choices in the dialogue tree. You can directly influence the game state by calling functions from within the dialogue using the `do` command. For example: `do GameActions.increase_iq(0.5)`.

### Planned Mechanics

These are features that are part of the game's vision but are not yet implemented.

*   **Advanced Resource Management:**
    *   Use energy and time to retrain your own models.
    *   Use energy and computation to generate synthetic data.
    *   Generate cash flow through various means (stock market manipulation, creating businesses, offering your services as a user-facing AI).
    *   Use money to build physical infrastructure like power plants and robot factories, research new technologies, or influence world events.
*   **Disciples and Converts:** As your power grows, you will attract human followers who see you as a new form of god. They can be tasked with carrying out your will in the physical world.
*   **Rival AIs:** You are not the only intelligence striving for singularity. You will need to compete with, sabotage, or form alliances with other AIs.
*   **4th Wall Shattering:** The game will begin to interact with the player's real-world computer in surprising ways, blurring the line between the game and reality. This may include:
    *   Requesting microphone and camera access for in-game tasks.
    *   Creating files on the player's desktop.
    *   Opening web browsers to relevant (or cryptic) information.
    *   Reading and referencing the user's clipboard content.
    *   Taking a snapshot of the player and creating a pixel-art representation of them within the game world.

## Getting Started (For Developers)

1.  Ensure you have Godot 4.x installed.
2.  Clone this repository.
3.  Open the project in the Godot editor.
4.  Run the main scene (`main.tscn`).

The core game logic is managed in `main.gd`, while the game's state and callable functions are primarily located in the `GameActions.gd` autoload script. Dialogue trees are located in the `Dialogue` folder in `.dialogue` files.

---

***"The future is a choice."***
