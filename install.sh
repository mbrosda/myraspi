#!/bin/bash

#------------------------------------------------
# initial settings
#------------------------------------------------
set -e
USERNAME=admin
mkdir -p ./status

#------------------------------------------------
# perform updates
#------------------------------------------------
[ ! -f ./status/update_done ]  && apt update     && touch ./status/update_done
[ ! -f ./status/upgrade_done ] && apt upgrade -y && touch ./status/upgrade_done

#------------------------------------------------
# Tools
#------------------------------------------------
[ ! -f ./status/tools1_installed ]               \
    && apt-get     -y install netcat-traditional \
    && apt         -y install nmap               \
    && apt-get     -y install telnet             \
    && apt-get     -y install jq                 \
    && touch ./status/tools1_installed

#------------------------------------------------
# mount my SSD
#------------------------------------------------
mkdir -p /ssd && chmod 777 /ssd
if grep '/ssd' /etc/fstab > /dev/null
then
    echo "SSD is already in /etc/fstab"
else
    echo "adding SSD to /etc/ fstab ..."
    echo "UUID=58131522-04c6-4a7b-9d48-5ab79f78f26a	/ssd	ext4	rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2" >> /etc/fstab
fi

if mount | grep '/ssd[	 ]*type' # [] contains TAB and SPACE
then
    echo "SSD is already mounted"
else
    echo "mounting SSD ..."
    mount /ssd
    systemctl daemon-reload
fi

#------------------------------------------------
# install docker and allow current user to use it
# see https://raspberrytips.com/docker-on-raspberry-pi/
#------------------------------------------------
[ ! -f ./status/docker_installed ]           \
    && curl -sSL https://get.docker.com | sh \
    && usermod -aG docker $USERNAME          \
    && touch ./status/docker_installed

#--------------------------------------------------------
# redirect docker directory (contains images etc.) to ssd
#--------------------------------------------------------
if [ -d "/ssd/docker" -a ! -f ./status/docker_redirected ]
then
    #----------------------------------------------------
    # update exiting daemon.json and point to /ssd/docker
    #----------------------------------------------------
    systemctl stop docker && echo "docker service stopped"
    if [ -f "/etc/docker/daemon.json" ]
    then
        jq '. += { "data-root": "/ssd/docker" }' < /etc/docker/daemon.json > /etc/docker/daemon.json.tmp \
            && mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json                                    \
            && chmod 644 /etc/docker/daemon.json
    else
        #------------------------------------------------
        # create new daemon.json and point to /ssd/docker
        #------------------------------------------------
        echo "{ \"data-root\": \"/ssd/docker\" }" > /etc/docker/daemon.json
        chmod 644 /etc/docker/daemon.json
    fi
    systemctl start docker && echo "docker service started"

    touch ./status/docker_redirected
fi

#------------------------------------------------
# UNINSTALL
#------------------------------------------------
#dpkg -l | grep docker
#apt remove docker-ce docker-ce-cli
#apt remove docker-ce docker-ce-cli docker-compose docker-compose-plugin docker.io python3-docker python3-dockerpty docker-buildx-plugin

# #------------------------------------------------
# # install preferences for docker in rootless mode
# #------------------------------------------------
# sh -eux <<EOF
# # Install newuidmap & newgidmap binaries
# apt-get install -y uidmap
# EOF
# 
# #------------------------------------------------
# # install docker rootless
# #------------------------------------------------
# dockerd-rootless-setuptool.sh install

#------------------------------------------------
# install docker-compose (+ prerequisites)
#------------------------------------------------

# pip3 install docker-compose # doesn't work any more, see also https://www.kali.org/blog/python-externally-managed/#:~:text=This%20environment%20is%20externally%20managed%20%E2%95%B0%E2%94%80%3E%20To%20install,a%20virtual%20environment%20using%20python3%20-m%20venv%20path%2Fto%2Fvenv.
# for docker-compose see https://stackoverflow.com/questions/75608323/how-do-i-solve-error-externally-managed-environment-every-time-i-use-pip-3

[ ! -f ./status/dockercompose_installed ] \
    && apt-get install -y libffi-dev libssl-dev \
    && apt     install -y python3-dev \
    && apt-get install -y python3 python3-pip \
    && apt install docker-compose \
    && echo "net.ipv4.ip_unprivileged_port_start=80" >> /etc/sysctl.conf \
    && sysctl --system \
    && touch ./status/dockercompose_installed

#------------------------------------------------
# tools
#------------------------------------------------
[ ! -f ./status/tools_installed ]           \
    && apt-get install -y apache2-utils     \
    && apt-get install -y dnsutils          \
    && apt     install -y mosquitto-clients \
    && touch ./status/tools_installed
