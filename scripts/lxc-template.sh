#!/bin/bash
set -e

echo "Starting package update and upgrade..."
apt update -y && apt upgrade -y

echo "Installing required packages..."
apt install git ansible python3-pip curl -y

echo "Creating user 'gla'..."
useradd -m -s /bin/bash gla
echo "gla:password123" | chpasswd
usermod -aG sudo gla

echo "Setting up SSH for 'gla'..."
mkdir -p /home/gla/.ssh
cp /root/.ssh/authorized_keys /home/gla/.ssh/
chown -R gla:gla /home/gla/.ssh
chmod 700 /home/gla/.ssh
chmod 600 /home/gla/.ssh/authorized_keys

echo "Disabling root SSH login..."
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

echo "Setting ping capabilities..."
setcap cap_net_raw+ep /bin/ping

echo "Cleaning up..."
apt-get clean
rm -rf /tmp/* /var/tmp/*
find /var/log -type f -exec truncate -s 0 {} \;
rm -f /etc/ssh/ssh_host_*
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id
rm -rf /home/*/.bash_history
rm -rf /root/.bash_history

echo "All tasks completed."