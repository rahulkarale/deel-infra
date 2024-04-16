sudo yum install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo amazon-linux-extras install epel -y
sudo yum install clamav clamd -y
sudo sed -i -e "s:#DatabaseDirectory /var/lib/clamav:DatabaseDirectory /var/lib/clamav:" /etc/freshclam.conf
sudo sed -i -e "s:#UpdateLogFile /var/log/freshclam.log:UpdateLogFile /var/log/freshclam.log:" /etc/freshclam.conf
sudo freshclam
sudo wget https://inspector-agent.amazonaws.com/linux/latest/install
sudo /bin/bash install && sudo rm -f install
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm 
sudo rpm -ivh amazon-cloudwatch-agent.rpm
sudo  rm -rvf  amazon-cloudwatch-agent.rpm
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${ssm_cloudwatch_config} -s
sudo systemctl status amazon-cloudwatch-agent.service
sudo sed -i "s/Ciphers.*/Ciphers aes128-ctr,aes192-ctr,aes256-ctr/g"   /etc/ssh/sshd_config
sudo sed -i "s/MACs.*/MACs hmac-sha1,umac-64@openssh.com,hmac-ripemd160/g" /etc/ssh/sshd_config
sudo systemctl restart sshd.service



