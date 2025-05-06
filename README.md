Net Switch: Network Adapter Mode Switcher

Net Switch is a powerful CLI tool designed to help you easily toggle between monitor mode and managed mode for your wireless network interfaces. Whether you're a network enthusiast, a penetration tester, or just want better control over your wireless adapter, Net Switch simplifies the process.
Features

    Toggle Monitor Mode: Seamlessly switch your wireless adapter between monitor mode and managed mode.

    Support for Multiple Interfaces: Automatically detects and lists available network interfaces, allowing you to select and control the desired one.

    Adapter Information: View detailed status of your selected adapter, including MAC address, mode, IP address (if in managed mode), and interface state.

    Colorful Output: Beautiful and easy-to-read output with color-coded information for better clarity.

    Sudo Authentication (Once): Sudo password is asked once at the beginning of the script. No repeated prompts.

    Safe Operation: Ensures that only the selected interface is affected, leaving others undisturbed.

Prerequisites

    Linux OS with tools such as iw and nmcli installed.

    Root/Sudo privileges to change network settings.

Installation

    Download the Script:

        Clone the repository or simply download the monitor_tool.sh file.

    Make the Script Executable:

        Open a terminal and run:

    chmod +x monitor_tool.sh

Run the Script:

    Execute the script with:

        ./monitor_tool.sh

Usage
Main Menu Options

After running the script, you'll be presented with a simple menu to interact with:

    Start Monitor Mode: Enable monitor mode for the selected network interface.

    Stop Monitor Mode: Switch the interface back to managed mode.

    Show Adapter Status: Display detailed status of the selected network interface.

    Change Adapter: Allows you to choose another network adapter.

    Exit: Exit the script.

Example Workflow:

    The script will first prompt you to select an interface from a list of available ones.

    Then, you can choose whether to enable monitor mode or disable it.

    You can check the status of the selected interface (e.g., mode, IP address, etc.) at any time.

    You can exit the tool when done or switch to a different interface.

Script Details

    Sudo Authentication: The script asks for the sudo password only once at the beginning, avoiding repeated prompts.

    Interface Mode Checking: The script automatically checks if the selected interface supports monitor mode before attempting to switch.

    Color-Coded Output: Output is color-coded for clarity:

        Green: Success or confirmation messages.

        Yellow: Warnings and status updates.

        Red: Errors or invalid actions.

        Cyan: General informational messages.

Troubleshooting

    "No wireless interfaces found"

        Ensure your wireless adapter is properly connected and supported.

        Verify that tools like iw and nmcli are installed.

    "Interface doesn't support monitor mode"

        Not all wireless network adapters support monitor mode. Check your adapter's compatibility with the command iw list.

    "Sudo authentication failed"

        Ensure that you enter the correct password when prompted. If the issue persists, check if you have sudo privileges.

Contributing

If you'd like to contribute to Net Switch, feel free to submit an issue or a pull request. Contributions, bug fixes, and improvements are always welcome!
License

This project is open-source and can be freely used, modified, and distributed under the MIT License.
Contact

For questions, feedback, or support, feel free to reach out.
