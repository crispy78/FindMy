# FindMy
Retrieve FindMy Objects data (Airtags, Airpods, etc.) from a jailbroken device and publish it through MQTT for use in Home Assistant

First of you'll need to install the Terminal & SSH addon (https://github.com/home-assistant/addons/blob/master/ssh/DOCS.md).
Secondly you'll need a (jailbroken) iOS device (iPhone / iPad) that supports Find My (iOS 14.0 or higher), I've used an iPhone 7 with iOS 15.7.4 and applied the Palera1n jailbreak.
Next thing to do was to add my Home Assistant SSH keys to the jailbroken iPhone; there a several instructions on the WWW on how to do that (for example https://youtu.be/_ANmn9QSLtA)
With Home Assistant now able to download the Items.data file the find_my.sh script will generate a device_tracker that you can use in your Maps-card for example.

The script is under development, so changes will me made.

## Home Assistant Configuration

### Find_my.sh
Copy the shell script to your prefered shell scripts location e.g. /config/shell/find_my
Change the listed variables to match your setup:
- scriptlocation
- iosdevice
- mqttbroker
- username
- password 

### Configuration.yaml
Add the following line to your configuration and modify it to match your setup.
`/config/ssh/id_rsa` should match the location of your ssh-key
`root@192.168.1.100` should match your SSH login
`/config/shell/find_my/find_my.sh` should match the location of find_my.sh

```
shell_command:
  find_my: ssh -i /config/ssh/id_rsa -o 'StrictHostKeyChecking=no' root@192.168.1.100 '/config/shell/find_my/find_my.sh'
```

### Automation
You can create an automation as basic as:
```
alias: "Run the Find_my script"
description: ""
trigger:
  - platform: time_pattern
    minutes: /5
condition: []
action:
  - service: shell_command.find_my
    data: {}
mode: single
```
