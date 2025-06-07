# BuddyBotUI Addon for mod-ollama-bot-buddy (WoW 3.3.5)

BuddyBotUI is a debugging addon for the [mod-ollama-bot-buddy](https://github.com/DustinHendrickson/mod-ollama-bot-buddy) AzerothCore module. It provides in-game, movable, and resizable panels displaying real-time bot state, commands, and reasoning information for **World of Warcraft 3.3.5 (Wrath of the Lich King, AzerothCore)**. This enables rapid testing and verification of bot behavior as it interacts with the Ollama LLM and AzerothCore world.

---

## Features

- **Live Debugging Panels**
    - **State Panel:** View the current state of the bot, including snapshot information and dynamic updates.
    - **Command/Reasoning Panel:** Displays the last five commands, including the associated reasoning or context.
- **Automatic In-Game Integration**
    - Panels show and update automatically during playtesting.
- **Movable and Resizable UI**
    - Each panel can be freely moved and resized via drag handles and corner grip.
- **Text Expansion**
    - Supports readable multiline formatting for long bot outputs or explanations.
- **Native AzerothCore Addon**
    - Integrates seamlessly with [mod-ollama-bot-buddy](https://github.com/DustinHendrickson/mod-ollama-bot-buddy) output, responding to bot debug messages sent over the in-game chat system.

---

## Installation

1. **Download the Files:**
    - `BuddyBotUI.xml`
    - `BuddyBotUI.lua`
    - `BuddyBotUI.toc`

2. **Copy to AddOns Folder:**  
   Place all files into a folder named `BuddyBotUI` inside your WoW 3.3.5 client’s `Interface/AddOns/` directory.

3. **Enable the Addon:**  
   Enable "BuddyBotUI" from the in-game AddOns menu before launching the game.

---

## Usage

1. **Start mod-ollama-bot-buddy** with your AzerothCore 3.3.5 server and test bots with the Ollama integration.
2. **In-game**, as soon as bot debug messages are sent, BuddyBotUI panels will appear and update automatically:
    - **BotBuddy State** panel: Shows overall snapshot and live bot status.
    - **BotBuddy Command** panel: Shows the last command, up to five most recent commands, and associated LLM reasoning.
3. **Move or resize** the panels as needed. You can drag by the top bar or resize using the grip in the lower right corner.

---

## File Overview

- **BuddyBotUI.xml**  
  Defines the two core frames:  
  - `BotBuddyStateFrame`: Main state display.  
  - `BotBuddyCommandFrame`: Command and reasoning details.
- **BuddyBotUI.lua**  
  Handles logic for:
    - Parsing and updating frame content in real time.
    - Responding to `[BUDDY_STATE]`, `[BUDDY_COMMAND]`, and `[BUDDY_REASON]` in-game messages.
    - Handling panel movement and resizing.
- **BuddyBotUI.toc**  
  Addon metadata file.

---

## Requirements

- **AzerothCore** server (3.3.5) running [mod-ollama-bot-buddy](https://github.com/DustinHendrickson/mod-ollama-bot-buddy)
- **World of Warcraft** 3.3.5 client supporting Lua/XML addons (Wrath of the Lich King)
- BuddyBotUI loaded as an enabled addon

---

## Troubleshooting

- If the panels do not appear, confirm that both the mod-ollama-bot-buddy module and BuddyBotUI addon are enabled and that the bot is generating debug output with `[BUDDY_STATE]`, `[BUDDY_COMMAND]`, or `[BUDDY_REASON]` tags in system chat.
- For panel issues, reload your UI with `/reload`.

---

## Credits

- Developed and maintained by [Dustin Hendrickson](https://github.com/DustinHendrickson).
- Designed for rapid prototyping and debugging of advanced bot AI in World of Warcraft 3.3.5 (AzerothCore).

