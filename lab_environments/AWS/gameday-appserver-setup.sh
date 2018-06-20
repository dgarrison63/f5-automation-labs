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


cat << 'EOF' >> /etc/ssh/sshd_config
Match address 10.1.1.0/24
    PasswordAuthentication yes

EOF
service ssh restart


