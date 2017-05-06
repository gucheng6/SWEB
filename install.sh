#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "Does not support this OS, Please contact the author! "
    kill -9 $$
fi


#Install Basic Tools
if [[ ${OS} == Ubuntu ]];then
	apt-get update
	apt-get install python -y
	apt-get install python-pip -y
	apt-get install git -y
	apt-get install language-pack-zh-hans -y
    apt-get install build-essential screen curl -y
fi
if [[ ${OS} == CentOS ]];then
	yum install python screen curl -y
	yum install python-setuptools -y && easy_install pip -y
	yum install git -y
    yum groupinstall "Development Tools" -y
fi
if [[ ${OS} == Debian ]];then
	apt-get update
	apt-get install python screen curl -y
	apt-get install python-pip -y
	apt-get install git -y
    apt-get install build-essential -y
fi

#Install SSR (Powered By Teddysun : https://shadowsocks.be/9.html)
wget https://raw.githubusercontent.com/FunctionClub/shadowsocks_install/master/shadowsocksR.sh
chmod +x shadowsocksR.sh
bash shadowsocksR.sh
rm -rf shadowsocksR.sh

#Install Caddy (Powered By Toyo : https://doub.io/shell-jc1/)
wget -N --no-check-certificate https://softs.pw/Bash/caddy_install.sh
chmod +x caddy_install.sh && bash caddy_install.sh install http.filemanager
rm -rf caddy_install.sh

#Install SWEB
cd /usr/local/
git clone https://github.com/FunctionClub/SWEB
chmod +x /usr/local/SWEB/cgi-bin

#Configure Caddy Proxy
echo ":80 {
 proxy / http://127.0.0.1:8000
}" > /usr/local/caddy/Caddyfile
service caddy restart

#Download SWEB Manager
wget -N --no-check-certificate -O /usr/local/bin/sweb https://raw.githubusercontent.com/FunctionClub/SWEB/master/sweb
chmod +x /usr/local/bin/sweb

#Start SWEB in Screen
cd /usr/local/SWEB
screen -dmS SWEB python CGIHTTPServer.py

#Install OK
echo "Install OK! Enjoy!"