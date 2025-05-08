#!/bin/bash

echo "Applying fix Radxa X4 NQC recovery bug"

DEFAULT_CONFIG=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub)
SDHCI_CONTROLLER=$(lspci | grep "SD Host")

if [[ $DEFAULT_CONFIG == *"sdhci.debug_quirks"* ]] || [ "$SDHCI_CONTROLLER" == "" ] || [ "$DEFAULT_CONFIG" == "" ]; then
    echo "No modification of Grub needed"
else
    echo "Forcing NCQ disabled for eMMC devices"
    NEW_CONFIG="${DEFAULT_CONFIG::-1}  sdhci.debug_quirks=0x20000\""
    sed -i "s/$DEFAULT_CONFIG/$NEW_CONFIG/" "/etc/default/grub"
    update-grub
fi

echo "Successfully applied fix Radxa X4 NQC recovery bug"