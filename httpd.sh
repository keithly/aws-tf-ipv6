#!/bin/bash -xe

# for debugging boot failures
exec > /tmp/userdata.log 2>&1

dnf -y update

sudo dnf install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello World" | sudo tee /var/www/html/index.html
