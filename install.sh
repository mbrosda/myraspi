#!/bin/bash

set -e

USERNAME=admin

mkdir -p ./status


# #------------------------------------------------
# # perform updates
# #------------------------------------------------
# apt update
# apt upgrade -y
# 
# #------------------------------------------------
# # Tools
# #------------------------------------------------
# apt-get -y install netcat-traditional
# apt-get -y install telnet
apt install -y nmap   # used for portscanning devices


#------------------------------------------------
# install docker and allow current user to use it
# see https://raspberrytips.com/docker-on-raspberry-pi/
#------------------------------------------------
[ ! -f ./status/docker_installed ] && curl -sSL https://get.docker.com | sh && usermod -aG docker $USERNAME && touch ./status/docker_installed

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
    && apt-get install -y jq                \
    && touch ./status/tools_installed

