#!/bin/bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor,
# and if deemed too high send the raw IPMI command to enable dynamic fan control.
#
# Requires:
# ipmitool – apt-get install ipmitool
# ----------------------------------------------------------------------------------


# IPMI SETTINGS:
# Modify to suit your needs.
# DEFAULT IP: 192.168.0.120
IPMIHOST=10.0.100.20
IPMIUSER=root
IPMIPW=calvin
IPMIEK=0000000000000000000000000000000000000000

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with.
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=32
DESIREDTEMP=27

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)


if [[ $TEMP > $MAXTEMP ]]; then
    echo "Temp is above max threshold. Fans reverting to automatic."
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01
  elif [[ $TEMP > $DESIREDTEMP ]]; then
    echo "Temp is between max and desired. Fans Unchanged."
  else
    echo "Temperature returned to below desired threshold. Fans dropping speed."
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x09
fi
