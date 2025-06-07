#!/bin/bash

DISKS=$(lsblk --noempty --nodeps --dedup NAME --json --bytes | jq '.blockdevices | map(select(.size>10000000000))')

ARG=${1:-"hide"}   

NUM_DISKS=$(echo "$DISKS" | jq length)
OLD_DISK_DATA=()
TIMESTAMP=$(date +%s)

for ((i = 0; i < NUM_DISKS; i++)) ; do
    DISK=$(echo $DISKS | jq -r ".[$i].name")
    DISK_DATA=$(smartctl --all "/dev/${DISK}" --json)

    ERROR=$(echo $DISK_DATA | jq -r ".smartctl.messages.[0].severity")

    if [ "$ERROR" == "error" ] || [ "$ERROR" == "null" ]; then
        continue
    fi

    SMART_ENABLED=$(echo $DISK_DATA | jq ".smart_support.enabled")

    if [ "$SMART_ENABLED" == "true" ] ; then
        STATUS="Failed"
        STATE="Degrading"
        MODEL=$(echo $DISK_DATA | jq -r '.model_name')
        MAKE=${MODEL:0:2}
        PASSED=$(echo $DISK_DATA | jq '.smart_status.passed')

        if [ "$PASSED" == "true" ] ; then
            STATUS="Passed"
            CURRENT_REALLOCATED_SECTORS=$(echo $DISK_DATA | jq '.ata_smart_attributes.table | map(select(.name=="Reallocated_Sector_Ct")) | .[0].raw.value')
            CURRENT_PENDING_SECTORS=$(echo $DISK_DATA | jq '.ata_smart_attributes.table | map(select(.name=="Current_Pending_Sector")) | .[0].raw.value')

            if [ -f "/opt/smart_monitor/hdd_${DISK}.temp" ] ; then
                mapfile -t OLD_DISK_DATA < /opt/smart_monitor/hdd_${DISK}.temp
                EXPIRES=${OLD_DISK_DATA[0]}
                PREVIOUS_REALLOCATED_SECTORS=${OLD_DISK_DATA[1]}
                PREVIOUS_PENDING_SECTORS=${OLD_DISK_DATA[2]}
                LAST_STABLE_REALLOCATED_SECTORS=${OLD_DISK_DATA[3]}
                LAST_STABLE_PENDING_SECTORS=${OLD_DISK_DATA[4]}
            else
                EXPIRES=$(( $TIMESTAMP + 1209600 )) # Keep current status for 2 weeks
                PREVIOUS_REALLOCATED_SECTORS=$CURRENT_REALLOCATED_SECTORS
                PREVIOUS_PENDING_SECTORS=$CURRENT_PENDING_SECTORS
                LAST_STABLE_REALLOCATED_SECTORS=$PREVIOUS_REALLOCATED_SECTORS
                LAST_STABLE_PENDING_SECTORS=$PREVIOUS_PENDING_SECTORS

                mkdir /opt/smart_monitor
                echo $EXPIRES > /opt/smart_monitor/hdd_${DISK}.temp
                echo $CURRENT_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                echo $CURRENT_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                echo $LAST_STABLE_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                echo $LAST_STABLE_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
            fi

            if [ $CURRENT_REALLOCATED_SECTORS -gt 0 ] || [ $CURRENT_PENDING_SECTORS -gt 0 ]; then
                STATUS="Warning"

                if [ $CURRENT_REALLOCATED_SECTORS -eq $PREVIOUS_REALLOCATED_SECTORS ] && [ $CURRENT_PENDING_SECTORS -eq $PREVIOUS_PENDING_SECTORS ]; then
                    if [ $TIMESTAMP -gt $EXPIRES ] ; then
                        STATE="Stable"
                        echo $EXPIRES > /opt/smart_monitor/hdd_${DISK}.temp
                        echo $CURRENT_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                        echo $CURRENT_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                        echo $CURRENT_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                        echo $CURRENT_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                    fi
                else
                    EXPIRES=$(( $TIMESTAMP + 1209600 )) # Keep current status for 2 weeks
                    echo $EXPIRES > /opt/smart_monitor/hdd_${DISK}.temp
                    echo $CURRENT_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                    echo $CURRENT_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                    echo $LAST_STABLE_REALLOCATED_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                    echo $LAST_STABLE_PENDING_SECTORS >> /opt/smart_monitor/hdd_${DISK}.temp
                fi
            else
                STATE="Stable"
            fi
        fi
        
        if [ "$MAKE" == "ST" ]; then
            TEMP=$(echo $DISK_DATA | jq '.ata_smart_attributes.table | map(select(.name=="Temperature_Celsius")) | .[0].value')
        elif [ "$MAKE" == "WD" ]; then
            TEMP=$(echo $DISK_DATA | jq '.ata_smart_attributes.table | map(select(.name=="Temperature_Celsius")) | .[0].raw.value')
        fi

        if [ "$ARG" == "show" ]; then
            echo '{"disk":"'${DISK}'","temperature":'${TEMP}',"status":"'${STATUS}'","state":"'${STATE}'","prev_pending_sectors":"'${LAST_STABLE_PENDING_SECTORS}'","current_pending_sectors":"'${CURRENT_PENDING_SECTORS}'","prev_reallocated_sectors":"'${LAST_STABLE_REALLOCATED_SECTORS}'","current_reallocated_sectors":"'${CURRENT_REALLOCATED_SECTORS}'"}' | jq '.'
        fi

        echo '{"disk":"'${DISK}'","temperature":'${TEMP}',"status":"'${STATUS}'","state":"'${STATE}'","prev_pending_sectors":"'${LAST_STABLE_PENDING_SECTORS}'","current_pending_sectors":"'${CURRENT_PENDING_SECTORS}'","prev_reallocated_sectors":"'${LAST_STABLE_REALLOCATED_SECTORS}'","current_reallocated_sectors":"'${CURRENT_REALLOCATED_SECTORS}'"}' > /opt/smart_monitor/hdd_${DISK}.status
    fi
done