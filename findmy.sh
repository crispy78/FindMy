#!/bin/bash

# Thanks for Airtag Alex for the inspiration and borrowing some of his code
# Visit his Youtube channel https://www.youtube.com/c/AirtagAlex or https://github.com/icepick3000/AirtagAlex

# This project is far from done and it still needs some work:
# - Instead of a device_tracker I would like to create a Device with a Device_tracker entity,

# Setting the variables
# location of the script
scriptlocation=/config/shell/find_my

# IP address of the jailbroken iOS device, accessible from HA through SSH
iosdevice=192.168.1.110

# IP address of the MQTT broker
mqttbroker=192.168.1.100

# MQTT broker username
mqttusername=username

# MQTT broker password
mqttpassword=password

# The script
rm $scriptlocation/Items.data  > /dev/null 2>&1
echo $(date -u) "- Delete Items.data"
echo $(date -u) "- Download Items.data from iOS device ($iosdevice)"
scp root@$iosdevice:/User/Library/Caches/com.apple.findmy.fmipcore/Items.data $scriptlocation/Items.data > /dev/null 2>&1

object=`cat $scriptlocation/Items.data | jq ".[].serialNumber" | wc -l`
echo $(date -u) "- Number of Apple Find My objects to process: $object"
object=`echo "$(($object-1))"`
echo "-----------------------------------------------------------------------------------------------------------------------------"
for j in $(seq 0 $object)

do
echo $(date -u) "- Gathering data from $scriptlocation/Items.data for next Apple Find My object to process"
datetime=`date +"%Y-%m-%d  %T"`

serialnumber=`cat $scriptlocation/Items.data | jq -r ".[$j].serialNumber"`
manufacturerName=`cat $scriptlocation/Items.data | jq -r ".[$j].productType.productInformation.manufacturerName"`
modelName=`cat $scriptlocation/Items.data | jq -r ".[$j].productType.productInformation.modelName"`
systemversion=`cat $scriptlocation/Items.data | jq -r ".[$j].systemVersion"`

antennapower=`cat $scriptlocation/Items.data | jq -r ".[$j].productType.productInformation.antennaPower"`
batterystatus=`cat $scriptlocation/Items.data | jq -r ".[$j].batteryStatus"`
name=`cat $scriptlocation/Items.data | jq -r ".[$j].name"`

locationtimestamp=`cat $scriptlocation/Items.data | jq -r ".[$j].location.timeStamp"`
locationpositiontype=`cat $scriptlocation/Items.data | jq -r ".[$j].location.positionType"`
locationlatitude=`cat $scriptlocation/Items.data | jq -r ".[$j].location.latitude"`
locationlongitude=`cat $scriptlocation/Items.data | jq -r ".[$j].location.longitude"`
locationverticalaccuracy=`cat $scriptlocation/Items.data | jq -r ".[$j].location.verticalAccuracy" | sed 's/null/0/g'`
locationhorizontalaccuracy=`cat $scriptlocation/Items.data | jq -r ".[$j].location.horizontalAccuracy" | sed 's/null/0/g'`
locationfloorlevel=`cat $scriptlocation/Items.data | jq -r ".[$j].location.floorlevel" | sed 's/null/0/g'`
locationaltitude=`cat $scriptlocation/Items.data | jq -r ".[$j].location.altitude" | sed 's/null/0/g'`
locationisinaccurate=`cat $scriptlocation/Items.data | jq -r ".[$j].location.isInaccurate" | awk '{ print "\""$0"\"" }'`
locationisold=`cat $scriptlocation/Items.data | jq -r ".[$j].location.isOld" | awk '{ print "\""$0"\"" }' `
locationfinished=`cat $scriptlocation/Items.data | jq -r ".[$j].location.locationFinished" | awk '{ print "\""$0"\"" }' `

addressmapItemFullAddress=`cat $scriptlocation/Items.data | jq -r ".[$j].address.mapItemFullAddress" | sed 's/null/""/g'`
addressstreetName=`cat $scriptlocation/Items.data | jq -r ".[$j].address.streetName"| sed 's/null/""/g'`
addressstreetaddress=`cat $scriptlocation/Items.data | jq -r ".[$j].address.streetAddress"| sed 's/null/""/g'`
addresslocality=`cat $scriptlocation/Items.data | jq -r ".[$j].address.locality"| sed 's/null/""/g'`
addressadministrativearea=`cat $scriptlocation/Items.data | jq -r ".[$j].address.administrativeArea"| sed 's/null/""/g'`
addressstatecode=`cat $scriptlocation/Items.data | jq -r ".[$j].address.stateCode" | sed 's/null/""/g'`
addresscountry=`cat $scriptlocation/Items.data | jq -r ".[$j].address.country"| sed 's/null/""/g'`
addresscountrycode=`cat $scriptlocation/Items.data | jq -r ".[$j].address.countryCode"| sed 's/null/""/g'`
addressareaofinteresta=`cat $scriptlocation/Items.data | jq -r ".[$j].address.areaOfInterest[0]" | sed 's/null/""/g'`
addressareaofinterestb=`cat $scriptlocation/Items.data | jq -r ".[$j].address.areaOfInterest[1]" | sed 's/null/""/g'`
echo $(date -u) "- Data gathered, going to send data to MQTT broker $mqttbroker"

echo $(date -u) "- Sending MQTT data of Apple Find My object: $name"
mosquitto_pub -h $mqttbroker -u $mqttusername -P $mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/config -m '{"unique_id": "'$serialnumber'", "~": "homeassistant/device_tracker/findmy_'$serialnumber'", "stat_t": "~/state", "json_attr_t": "~/attributes", "name": "Apple FindMy '$name'"}'
mosquitto_pub -h $mqttbroker -u $mqttusername -P $mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/state -m ''"$addressmapItemFullAddress"''
mosquitto_pub -h $mqttbroker -u $mqttusername -P $mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/attributes -m '{"latitude": '$locationlatitude', "longitude": '$locationlongitude', "altitude": '$locationaltitude', "vertical accuracy": '$locationverticalaccuracy',"horizontal accuracy": '$locationhorizontalaccuracy', "battery_level": '$batterystatus', "antenna_power": '$antennapower'}'
echo -e $(date -u) "- Transfer of MQTT data completed \n"
done
