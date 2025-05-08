#!/bin/bash

(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ ${SOURCED} -eq 0 ]; then
    echo "Script is executing standalone. Using config in script"

    #Variables
    HDD_IDS=()                                              #The IDs of the HDD's you wan to add to the pool - Get from: ls -l /dev/disk/by-id
    MERGERFS_DIR="default"                                  #The directory name where the merged folder should be mounted
    READ_ONLY_SHARES=no                                     #Should the shared folder be read-only
    
    #Common Scripts
    source "../secrets.sh"
    source "../common/disable_ip_v6.sh"
    source "../common/common_variables.sh"
fi

REMOTE_USER=$SAMBA_USER                                 #User to use for the SAMBA share. You will connect with this user.
REMOTE_PASS=$SAMBA_PASS                                 #The above user's password.


echo "-----------------------------Installing MergerFS-----------------------------"

echo "Setting up Shared Folders"
apt install samba mergerfs smartmontools ntfs-3g -y

#TODO: Fix usb hdd detection

if [ ${#HDD_IDS[@]} -eq 0 ]; then
    echo "No HDD configured using default options"
    echo "Seaching for suitable drives..."

    ls /dev/disk/by-id | grep -v "part\|DVD\|CD\|mmc" | grep "ata\|usb" | while read -r DRIVE ; do
        echo "Found Drive: $DRIVE"

        PARTITIONS=$(ls /dev/disk/by-id | grep "$DRIVE-part1")
        
        ls /dev/disk/by-id | grep "$DRIVE-part" | while read -r PARTITION ; do
            MOUNT_POINT=$(lsblk -r /dev/disk/by-id/$PARTITION | grep "sd" | cut -d " " -f 7)
            FSTYPE=$(lsblk -n -o FSTYPE /dev/disk/by-id/$PARTITION)
            
            if [ -z ${MOUNT_POINT} ]; then
                echo "  Found Partition: $PARTITION which is not mounted"

                if [ -z ${FSTYPE} ]; then
                    echo "      Partition $PARTITION is not formatted. Formatting now..."
                    mkfs.ntfs -f /dev/disk/by-id/$PARTITION
                fi

                echo "      Adding partition to MergerFS Pool"
                echo $PARTITION >> hdd_ids.temp
            else
                echo "  Found Partition: $PARTITION mounted at $MOUNT_POINT"

                if [ "$MOUNT_POINT" = "/" ] || [[ "$MOUNT_POINT" = "/var/"* ]] || [[ "$MOUNT_POINT" = "/boot/"* ]] || [[ "$MOUNT_POINT" = "/root/"* ]] || [[ "$MOUNT_POINT" = *"/snap/"* ]] || [[ "$MOUNT_POINT" = *"/run/"* ]] || [[ "$MOUNT_POINT" = *"/dev/"* ]] || [[ "$MOUNT_POINT" = *"/sys/"* ]]; then
                    echo "      Partition mounted on root: skipping"
                else

                    echo "      Adding partition to MergerFS Pool"
                    echo $PARTITION >> hdd_ids.temp
                fi
            fi
        done
        
        if [ -z ${PARTITIONS} ]; then
            echo "  Drive has no partitions: "
            echo "  Attempting to create them now..."

            sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/disk/by-id/$DRIVE
                o # clear the in memory partition table
                n # new partition
                p # primary partition
                1 # partition number 1
                    # default, start immediately after preceding partition
                    # default, extend partition to end of disk
                p # print the in-memory partition table
                w # write the partition table
                q # and we're done
EOF
            sleep 5
            PARTITION=$(ls /dev/disk/by-id | grep "$DRIVE-part1")

            echo "  Formatting with NTFS:"
            mkfs.ntfs -f /dev/disk/by-id/$PARTITION

            echo "Adding to MergerFS pool"
            echo $PARTITION >> hdd_ids.temp
        fi
    done
fi

if [ ${#HDD_IDS[@]} -eq 0 ]; then
    mapfile -t HDD_IDS < hdd_ids.temp
    rm -f hdd_ids.temp
fi

if [ ${#HDD_IDS[@]} -eq 0 ]; then
    echo "No suitable drives found for MergerFS. Skipping setup"
else
    echo "Configuring MergerFS:"

    COUNTER=1
    for HDD_ID in ${HDD_IDS[@]}; do
        HDD=$(ls /dev/disk/by-id | grep "$HDD_ID")

        if [ -z ${HDD} ]; then
            echo "Invalid disk ID: $HDD_ID, skipping"
            continue
        fi

        FSNAME=$(lsblk -n -o NAME /dev/disk/by-id/$HDD_ID)
        FSTYPE=$(lsblk -n -o FSTYPE /dev/disk/by-id/$HDD_ID)

        if grep -F "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER" /etc/fstab ; then
            echo "Found existing disk: $FSNAME, with partition type: $FSTYPE, mounted on: /mnt/disk$COUNTER"
            COUNTER=$[ $COUNTER + 1 ]
            continue
        fi

        echo "Detected new disk: $FSNAME with partition type: $FSTYPE"

        mkdir -p /mnt/disk$COUNTER
        if [ "$FSTYPE" == "ntfs" ]; then
            echo "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER   $FSTYPE defaults,nofail,big_writes,gid=$APP_GUID,uid=$APP_UID,umask=000,dmask=000,fmask=000 0 0" >> /etc/fstab
        else
            echo "/dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER   $FSTYPE defaults,nofail 0 0" >> /etc/fstab
        fi

        mount /dev/disk/by-id/$HDD_ID /mnt/disk$COUNTER
        COUNTER=$[ $COUNTER + 1 ]
    done

    if [ "$MERGERFS_DIR" == "default" ]; then
        MERGERFS_DIR="nas"
    fi

    if grep -F "/mnt/disk* /mnt/$MERGERFS_DIR fuse.mergerfs" /etc/fstab ; then
        echo "MergerFS already found"
    else
        mkdir -p /mnt/$MERGERFS_DIR

        echo "/mnt/disk*/ /mnt/$MERGERFS_DIR fuse.mergerfs defaults,nonempty,allow_other,use_ino,cache.files=off,category.create=mfs,moveonenospc=true,dropcacheonclose=true,minfreespace=10G,fsname=mergerfs 0 0" >> /etc/fstab
        mergerfs -o defaults,nonempty,allow_other,use_ino,cache.files=off,category.create=mfs,moveonenospc=true,dropcacheonclose=true,minfreespace=10G,fsname=mergerfs /mnt/disk\* /mnt/$MERGERFS_DIR
    fi

    if [ "$REMOTE_USER" == "default" ]; then
        REMOTE_USER=$SUDO_USER
    else
        useradd -r $REMOTE_USER
        sleep 1
        echo -ne "$REMOTE_PASS\n$REMOTE_PASS\n" | passwd -q $REMOTE_USER
    fi

    chown -R $APP_UID:$APP_GUID /mnt/$MERGERFS_DIR
    echo "Created /mnt/$MERGERFS_DIR using mergerfs."
    echo "Creating SAMBA Shares:"

    if grep -F "comment = MergerFS Share" /etc/samba/smb.conf ; then
        echo "Share Already Exists"
    else
        echo "[$MERGERFS_DIR]" >> /etc/samba/smb.conf
        echo "    comment = MergerFS Share" >> /etc/samba/smb.conf
        echo "    path = /mnt/$MERGERFS_DIR" >> /etc/samba/smb.conf
        echo "    read only = $READ_ONLY_SHARES" >> /etc/samba/smb.conf
        echo "    browsable = yes" >> /etc/samba/smb.conf
        echo "    force user = $APP_UID" >> /etc/samba/smb.conf
        echo "    force group = $APP_GUID" >> /etc/samba/smb.conf
        echo "    create mask = 775" >> /etc/samba/smb.conf
        echo "    directory mask = 775" >> /etc/samba/smb.conf

        service smbd restart
        echo -ne "$REMOTE_PASS\n$REMOTE_PASS\n" | smbpasswd -a -s $REMOTE_USER
    fi
    SMB_URL="smb://$IP_LOCAL/$MERGERFS_DIR"
    echo "Samba share can now be accessed at: $SMB_URL"
fi

echo "Installled MergerFS"