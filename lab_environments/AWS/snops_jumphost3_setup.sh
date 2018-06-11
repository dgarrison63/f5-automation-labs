#!/bin/bash

# The purpose of this script is to setup the required components for the F5
# automation lab Linux jumphost
#
# This script is processed by cfn-init and will be run as root.
#
# You can monitor the progress of the packages install through
# /var/log/cfn-init-cmd.log. Here you will see all the different commands run
# from the Cloud Formation Template and through this script
#
# It takes approx. 10-15 min to have the RDP instance fully setup

set -x

apt update
apt install -y common-software-properties
apt update

# Install desktop environment
apt-get -y install xrdp xfce4


# Upgrade xrdp and install xorgxrdp
apt-get -y install git 

systemctl daemon-reload
systemctl enable xrdp

# Configure xrdp

cat << 'EOF' > /etc/xrdp/xrdp.ini
[Globals]
ini_version=1
fork=true
port=3389
tcp_nodelay=true
tcp_keepalive=true
security_layer=negotiate
crypt_level=high
certificate=
key_file=
ssl_protocols=TLSv1, TLSv1.1, TLSv1.2
autorun=supernetops
allow_channels=true
allow_multimon=true
bitmap_cache=true
bitmap_compression=true
bulk_compression=true
max_bpp=16
new_cursors=true
use_fastpath=both

[Logging]
LogFile=xrdp.log
LogLevel=DEBUG
EnableSyslog=true
SyslogLevel=DEBUG

[Channels]
rdpdr=true
rdpsnd=true
drdynvc=true
cliprdr=true
rail=true
xrdpvr=true
tcutils=true

[supernetops]
name=Super-NetOps
lib=libxup.so
username=ec2-user
password=supernetops
ip=127.0.0.1
port=-1
code=20

EOF

sh -c 'echo "xfce4-session" > /home/ec2-user/.xsession'
chown -R ec2-user:ec2-user /home/ec2-user/.xsession

sed -i.bak "s/FuseMountName=thinclient_drives/FuseMountName=remote_drives/g" /etc/xrdp/sesman.ini
systemctl start xrdp
systemctl start xrdp-sesman


# enable/start vncserver/noVNC
systemctl daemon-reload

# Install Chrome setup and add the desktop icon
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get -y update
apt-get -y install google-chrome-stable

# Disable SSH Host Key Checking for hosts in the lab
cat << 'EOF' >> /etc/ssh/ssh_config

Host 10.1.*.*
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null
   LogLevel ERROR

EOF


# Install Postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
tar -xzf postman.tar.gz -C /opt
rm postman.tar.gz
ln -s /opt/Postman/Postman /usr/bin/postman

# Setup Desktop icons
mkdir /home/ec2-user/Desktop

cat << 'EOF' > /home/ec2-user/Desktop/Chrome.desktop
[Desktop Entry]
Version=1.0
Name=Chrome
Comment=Open Chrome
Exec=/opt/google/chrome/chrome --wm-window-animations-disabled
Icon=/opt/google/chrome/product_logo_48.png
Terminal=false
Type=Application
Categories=Internet;Application;
EOF

chmod +x /home/ec2-user/Desktop/Chrome.desktop

cat << 'EOF' > /home/ec2-user/Desktop/Terminal.desktop
[Desktop Entry]
Version=1.0
Name=Terminal
Comment=Open Terminal
Exec=mate-terminal
Icon=utilities-terminal
Type=Application
Categories=System;GTK;Utility;TerminalEmulator;
EOF

chmod +x /home/ec2-user/Desktop/Terminal.desktop

cat << 'EOF' > /home/ec2-user/Desktop/RootTerminal.desktop
[Desktop Entry]
Version=1.0
Name=Root Terminal
Comment=Open Terminal
Exec=sudo mate-terminal
Icon=utilities-terminal
Type=Application
Categories=System;GTK;Utility;TerminalEmulator;
EOF

chmod +x /home/ec2-user/Desktop/RootTerminal.desktop

cat << 'EOF' > /home/ec2-user/Desktop/Postman.desktop
[Desktop Entry]
Version=1.0
Name=Postman
Comment=Open Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Utility;Application;
EOF

chmod +x /home/ec2-user/Desktop/Postman.desktop

# Set background image
wget https://github.com/f5devcentral/f5-automation-labs/raw/master/files/misc/supernetops.png -O /usr/share/backgrounds/mate/desktop/supernetops.png
cat << 'EOF' >> /home/ec2-user/.profile
gsettings set org.mate.background picture-filename '/usr/share/backgrounds/mate/desktop/supernetops.png'
gsettings set org.mate.background primary-color '#000000000000'
gsettings set org.mate.background picture-options 'centered'
gsettings set org.mate.background color-shading-type 'solid'
EOF

# Things are created as root, need to transfer ownership
chown -R ec2-user:ec2-user /home/ec2-user/Desktop
chown -R ec2-user:ec2-user /home/ec2-user/f5-automation-labs
