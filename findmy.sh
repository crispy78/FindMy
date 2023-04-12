#!/bin/bash

# Thanks for Airtag Alex for the inspiration and borrowing some of his code
# Visit his Youtube channel https://www.youtube.com/c/AirtagAlex or https://github.com/icepick3000/AirtagAlex

# This project is far from done and it still needs some work:
# - Instead of a device_tracker I would like to create a Device with a Device_tracker entity,
# - In my setup it has difficulty with the logbook entries and history.

# Setting the variables
# location of the script
scriptlocation=/config/custom_components/find_my

# IP address of the jailbroken iOS device, accessible from HA through SSH
iosdevice=192.168.1.101

# IP address of the MQTT broker
mqttbroker=192.168.1.10

# MQTT broker username
mqttusername=username

# MQTT broker password
mqttpassword=password


#Start an infinite loop
while :
do

	scp root@$iosdevice:/User/Library/Caches/com.apple.findmy.fmipcore/Items.data $scriptlocation/Items.data

  airtagsnumber=`cat $scriptlocation/Items.data | jq ".[].serialNumber" | wc -l`
	airtagsnumber=`echo "$(($airtagsnumber-1))"`

	for j in $(seq 0 $airtagsnumber)
	do
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

  mosquitto_pub -h $mqttbroker -u $mqttusername -P mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/config -m '{"~": "homeassistant/device_tracker/findmy_'$serialnumber'", "stat_t": "~/state", "json_attr_t": "~/attributes", "name": "Apple FindMy '$name'"}'
	mosquitto_pub -h $mqttbroker -u $mqttusername -P mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/state -m ''"$addressmapItemFullAddress"''
	mosquitto_pub -h $mqttbroker -u $mqttusername -P mqttpassword -t homeassistant/device_tracker/findmy_$serialnumber/attributes -m '{"latitude": '$locationlatitude', "longitude": '$locationlongitude', "altitude": '$locationaltitude', "vertical accuracy": '$locationverticalaccuracy',"horizontal accuracy": '$locationhorizontalaccuracy', "battery_level": '$batterystatus', "antenna_power": '$antennapower'}'

	done
	sleep 60

done