#!/bin/bash -v
apt-get update -y

ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id | tr -d 'i-'`
REGION="`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAGNAME="mongo-slave-${ID}"

apt-get install -y python-pip
pip install awscli
apt-get install git

aws ec2 create-tags --region $REGION --resources "i-${ID}" --tags Key=Name,Value=$TAGNAME

mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat > /root/.ssh/id_rsa <<EOF
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----
EOF
chmod 400 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts
curl -L https://www.opscode.com/chef/install.sh | sudo bash
cd /tmp; git clone git@github.com:maxc0d3r/swapstech.git
cat > /tmp/node.json <<EOF
{ "mongo_instance_type": "slave" }
EOF
chef-solo -c /tmp/chef/solo.rb -o base,mongo
