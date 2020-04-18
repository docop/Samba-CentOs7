#!/bin/sh
# Samba install script for CentOS 7 by lucandroid70@gmail.com
yum install -y samba samba-client samba-common

#Tout commande pr faire un serveur Samba, pr windows. en mode Anonyme et avec user!
#dns Win10 : fait Run: met : \\64.137.22.225  et ca ouvre direct un win explorer avec 2 folder
#un folder : Anonymous et un Secure. Pr ouvrir le Secure: ca va demander un psw. ici: user: cloud
# le mode script ne marche pas. Mais toute les commande ci-dessous. c OK

sudo systemctl enable firewalld
#si une new VM centos7 min : faire apres: yum update   / reboot.
# au reboot, faire: sudo firewall-cmd --state  , ca va dire : running. 

mv /etc/samba/smb.conf /etc/samba/_smb.conf

#ici ca fait un nouveau fichier et on colle cela dedans.
#juste a faire: vi
vi /etc/samba/smb.conf

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
#ne pas mettre EOF.   juste :wq

useradd cloud
groupadd smbshared
usermod -a -G smbshared cloud

mkdir -p /opt/shared
chmod -R 0777 /opt/shared
chown -R nobody:nobody /opt/shared
chcon -t samba_share_t /opt/shared

mkdir /opt/secure
chmod -R 0777 /opt/secure
chown -R cloud:smbshared /opt/secure
chcon -t samba_share_t /opt/secure

firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --reload

systemctl enable smb.service
systemctl enable nmb.service
systemctl restart smb.service
systemctl restart nmb.service

# insert password for user 'cloud'
smbpasswd -a cloud
#fin.  Le serveur roule et tout est accessible depuis win10 ou netboot!
#pr aller sur le folder : Secure, ca va demanderle user/pwd. met cloud et pw: celui que l'on a mit.
