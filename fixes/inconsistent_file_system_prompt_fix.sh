#!/bin/bash

echo "Applying fix for inconsistent file system prompt"
DEFAULT_CONFIG=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub)

if [[ $DEFAULT_CONFIG == *"fsck.mode=force"* ]] || [ "$DEFAULT_CONFIG" == "" ] ; then
    echo "No modification of Grub needed"
else
    echo "Forcing Grub to disk check and repair if the system was not rebooted properly"
    NEW_CONFIG="${DEFAULT_CONFIG::-1}  fsck.mode=force  fsck.repair=yes\""
    sed -i "s/$DEFAULT_CONFIG/$NEW_CONFIG/" "/etc/default/grub"
    update-grub
fi