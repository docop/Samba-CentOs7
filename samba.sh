#!/bin/sh
# Samba install script for CentOS 7 by lucandroid70@gmail.com
yum install -y samba samba-client samba-common

mv /etc/samba/smb.conf /etc/samba/_smb.conf

cat >> /etc/samba/smb.conf << EOF
[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = smbshared 
security = user
map to guest = bad user
dns proxy = no

# Private shared directory
[Secure]
path = /opt/secure
valid users = @smbshared
guest ok = no
writable = yes
browsable = yes

# Anonymous shared 
[Anonymous]
path = /opt/shared
browsable =yes
writable = yes
guest ok = yes
read only = no
EOF

useradd luke
groupadd smbshared
usermod -a -G smbshared luke

mkdir -p /opt/shared
chmod -R 0777 /opt/shared
chown -R nobody:nobody /opt/shared
chcon -t samba_share_t /opt/shared

mkdir /opt/secure
chmod -R 0777 /opt/secure
chown -R luke:smbshared /opt/secure
chcon -t samba_share_t /opt/secure

firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --reload

systemctl enable smb.service
systemctl enable nmb.service
systemctl restart smb.service
systemctl restart nmb.service

# insert password for user 'luke'
smbpasswd -a luke
