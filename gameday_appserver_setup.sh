#!/bin/bash

# The purpose of this script is to setup the required components for the F5
# automation lab Linux server
#
# This script is processed by cfn-init and will be run as root.
#
# You can monitor the progress of the packages install through
# /var/log/cfn-init-cmd.log. Here you will see all the different commands run
# from the Cloud Formation Template and through this script
#
# It takes approx. 5 min to have the instance fully setup

ifconfig eth1 10.1.10.100 netmask 255.255.255.0
ifconfig eth1:1 10.1.10.101 netmask 255.255.255.0
ifconfig eth1:2 10.1.10.102 netmask 255.255.255.0
ifconfig eth1:3 10.1.10.103 netmask 255.255.255.0


cat << 'EOF' >> /etc/ssh/sshd_config
Match address 10.1.1.0/24
    PasswordAuthentication yes

EOF
service ssh restart

# Install dnsmasq
apt-get install -y dnsmasq
cat << 'EOF' > /etc/dnsmasq.d/supernetops
listen-address=127.0.0.1,10.1.10.100,10.1.10.101,10.1.10.102,10.1.10.103
no-dhcp-interface=lo0,eth1,eth1:1,eth1:2,eth1:3
EOF
systemctl enable dnsmasq.service
service dnsmasq start

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce
systemctl enable docker
systemctl start docker


# start damn vulnerable web app container
docker run -d vulnerables/web-dvwa

# Start the f5-demo-httpd container

sh /etc/rc.local
