#!/bin/bash

#------------------------------------------------
# perform updates
#------------------------------------------------
[ ! -f ./status/update_done ]  && apt update     && touch ./status/update_done
[ ! -f ./status/upgrade_done ] && apt upgrade -y && touch ./status/upgrade_done

#------------------------------------------------
# Tools
#------------------------------------------------
[ ! -f ./status/netcat_installed ]  && apt-get -y install netcat-traditional && touch ./status/netcat_installed
[ ! -f ./status/telnet_installed ]  && apt-get -y install telnet             && touch ./status/telnet_installed


if grep '/ssd' /etc/fstab > /dev/null
then
    echo "SSD is already in /etc/fstab"
else
    echo "adding SSD to /etc/ fstab ..."
    echo "UUID=58131522-04c6-4a7b-9d48-5ab79f78f26a	/ssd	ext4	rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2" >> /etc/fstab
fi

