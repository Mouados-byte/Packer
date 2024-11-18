#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx git docker.io
sudo systemctl enable nginx
sudo systemctl start nginx
sudo docker pull your-app-image:latest
sudo docker run -d your-app-image:latest