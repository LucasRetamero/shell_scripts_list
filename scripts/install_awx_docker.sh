#!/bin/sh
echo "Options(Write only the number):
      1-: Install environment and download awx-17.10,
      2-: Generate pwgen passwod,
      3-: Download awx-17.10 and unzip fil"
read input_user

case $input_user in
1)
echo "========= Update packages and install docker tools ========="
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo "========= Use docker command without sudo ========="
sudo usermod -aG docker $USER

echo "========= Restart docker service ========="
sudo systemctl restart docker

echo "========= Install docker compose ========="
sudo chmod +x ../files/docker-compose-linux-x86_64
sudo mv ../files/docker-compose-linux-x86_64 /usr/local/bin/docker-compose

echo "========= Install nodejs ========="
sudo apt install -y nodejs npm
sudo npm install npm --global

echo "========= Install python3-pip, git and pwgen ========="
sudo apt install -y python3-pip git pwgen

echo "========= Install docker-compose version 1.28.5 ========="
sudo pip3 install docker-compose==1.28.5

echo "========= Download awx 17.1.0 and unzip file ========="
wget https://github.com/ansible/awx/archive/17.1.0.zip
unzip 17.1.0.zip ;;
2)
pwgen -N 1 -s 30 ;;
3)
echo "========= Download awx 17.1.0 and unzip file ========="
wget https://github.com/ansible/awx/archive/17.1.0.zip
unzip 17.1.0.zip ;;
esac
