#!/bin/bash -v
apt-get update -y

ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-'`
HOSTNAME="tomcat-${ID}"
DOMAIN="prod.upwork.org"
hostnamectl set-hostname $HOSTNAME
echo $HOSTNAME > /var/lib/cloud/data/previous-hostname
sed -i "s/^127.0.0.1.*/127.0.0.1\ $HOSTNAME\ $HOSTNAME.${DOMAIN} localhost localhost.localdomain localhost4 localhost4.localdomain4/g" /etc/hosts

apt-get install -y python-pip
pip install awscli

aws ec2 create-tags --region us-east-1 --resources "i-${ID}" --tags Key=Name,Value=$HOSTNAME

apt-get install -y nginx > /tmp/nginx.log
