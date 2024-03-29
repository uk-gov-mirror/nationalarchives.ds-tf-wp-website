#!/bin/bash

# Update yum
sudo yum update -y

# Mount EFS storage
sudo mkdir -p ${mount_dir}
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${mount_target}:/ ${mount_dir}
sudo chmod 777 ${mount_dir}
cd ${mount_dir}
sudo chmod go+rw .
cd /

# Auto mount EFS storage on reboot
sudo echo "${mount_target}:/ ${mount_dir} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,fsc,_netdev 0 0" >> /etc/fstab

# Link directory to EFS mount directory
sudo ln -snf ${mount_dir} /var/nationalarchives.gov.uk

# Install nginx
sudo amazon-linux-extras install -y nginx1

sudo systemctl enable --now nginx

# Copy configuration file
sudo aws s3 cp s3://${deployment_s3_bucket}/${service}/${nginx_conf_s3_key} /etc/nginx/nginx.conf

# Restart nginx to reload new config file
sudo systemctl restart nginx
