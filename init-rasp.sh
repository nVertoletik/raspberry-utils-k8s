#!/bin/bash
apt-get update && apt-get upgrade -y
name=$1
hostnamectl set-hostname $name
sed -i -e "s/127.0.0.1 localhost/127.0.0.1 localhost\n127.0.0.1 $name/g" /etc/hosts
sed -i -e "s/preserve_hostname: false/preserve_hostname: true/g" /etc/cloud/cloud.cfg
cat << EOT >> /boot/firmware/usercfg.txt
dtoverlay=pi3-disable-bt
dtoverlay=pi3-disable-wifi
EOT
sed -i -e 's/fixrtc/fixrtc cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory/g' /boot/firmware/nobtcmd.txt
swapoff -a
systemctl stop systemd-resolved
systemctl disable systemd-resolved
unlink /etc/resolv.conf
cat << EOT >> /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOT

#sed -i -e 's///g' $HOME/.bashrc
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository    "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker $USER
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update && apt-get install -y kubelet kubeadm kubectl
echo "net.bridge.bridge-nf-call-iptables=1" | tee -a /etc/sysctl.conf

