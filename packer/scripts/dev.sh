#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx git
sudo systemctl enable nginx
sudo systemctl start nginx
