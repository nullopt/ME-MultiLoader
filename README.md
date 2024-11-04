# ME-MultiLoader

## What is ME-MultiLoader?

ME-MultiLoader is a script that allows you to load multiple scripts at once. It is designed to manage and execute various ME scripts efficiently, providing a GUI for easy interaction and control.

## Features

- **Script Management**: Load and unload multiple scripts dynamically.
- **Quick Script Reloading**: Reload a script without having to reload the entire MultiLoader - useful for development.
- **Graphical User Interface**: A GUI to manage scripts, view status, and interact with the system.
- **Timer Utilities**: Built-in timer utilities for managing script execution intervals. This allows for asynchronous execution of scripts.
- **Customizable**: Easily add new scripts and manage existing ones through a script map.

## Components

### `multiLoader.lua`

The main component responsible for loading and managing scripts. It initializes the GUI and handles the script execution loop.

### `scriptMap.lua`

A mapping of categories and script names to their respective file paths, allowing the MultiLoader to dynamically load scripts.  
This is where you should add your scripts paths.


### `utilities/timer.lua`

A utility module for managing timed execution of scripts. It provides functions to create and check timers with random delays, all while being asynchronous and not blocking the main thread, or other scripts.  
**This should completely replace all blocking sleeps in your scripts.**  
(ie: `API.RandomSleep2(1000, 0, 0)` should be replaced with `TIMER:createSleep("SCRIPT_NAME", 1000)`)

### `ui/gui.lua` - Heavily modified version of [GUI Library - Jethrootje](https://discord.com/channels/809828167015596053/1143086122004643951)

A module for creating and managing the GUI. It provides functions to create and update the GUI elements, as well as handle user interactions.


## Example Scripts

- **Ink Maker**: Automates the process of making regular ink from ashes and vials of water.

- **Fungus Ash Generator**: Automates the collection of glowing fungus and conversion to ashes.


## Getting Started

1. **Clone the Repository**: Clone the project repository to your local machine.
2. **Install into your ME scripts**: Copy all the files into your `Lua_Scripts` folder.
3. **Run the MultiLoader**: Load the `multiLoader.lua` script from the `LoadLua` button once injected.
4. **Select the scripts you want to load**: Use the checkboxes to select which scripts to load/unload.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any enhancements or bug fixes.

## Contact

For any questions or support, please contact the project maintainers.

---

This README provides an overview of the ME-MultiLoader project, its components, and how to get started. For more detailed information, refer to the individual script files.

## License

This project is licensed under the GNU General Public License v3.0. For more details, see the LICENSE file.
