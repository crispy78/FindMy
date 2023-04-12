# FindMy
Retrieve FindMy Objects data (Airtags, Airpods, etc.) from a jailbroken device and publish it through MQTT for use in Home Assistant

In my case I've used a spare iPhone 7 with iOS 15.7.4 and applied the Palera1n jailbreak.
Next thing to do was to add my Home Assistant SSH keys to the jailbroken iPhone; there a several instructions on the WWW on how to do that (I'll try to find a suitable one to link to).
With Home Assistant now able to download the Items.data file the script will generate a device_tracker that you can use in your Maps-card for example.

The script is far from perfect and in my Home Assistant it has difficulty with the logbook and state history, but that's a work-in-progress.
