#!/bin/bash

echo "Update apt source list"

sudo apt-get update

echo "Install Updates"

sudo apt-get -y upgrade

echo "Create Database user for Odoo"

echo "Case doesn't work run it: sudo su - postgres -c 'createuser -s odoo'"
sudo su postgres <<HERE
cd

createuser -s $odoo_name

HERE

echo "Create Odoo Log File"

sudo mkdir /var/log/$odoo_name

sudo chown -R $odoo_name:root /var/log/$odoo_name

echo "Edit Odoo configuration file"

echo "[options]

; This is the password that allows database operations:

admin_passwd = sHv0n9hOrshd)

db_host = False

db_port = False

db_user = $username

db_password = False

http_port = $odoo_port

logfile = /var/log/$odoo_name/odoo-server.log

addons_path = /opt/$odoo_name/odoo_br/addons,/opt/$odoo_name/odoo_br/odoo/addons,/opt/$odoo_name/odoo_br/odoo-brasil" | sudo tee -a /etc/$odoo_name.conf

sudo chown $odoo_name: /etc/$odoo_name.conf

echo "Making an odoo service and start it"

echo "Edit Odoo server file"

echo "[Unit]
Description=$odoo_name
Requires=postgresql.service
After=network.target postgresql.service

[Service]
# Ubuntu/Debian convention:
Type=simple
User=$username
ExecStart=/opt/$odoo_name/odoo_br/odoo-bin -c /etc/$odoo_name.conf
StandardOutput=journal+console

[Install]
WantedBy=default.target" | sudo tee -a /etc/systemd/system/$odoo_name.service

sudo chmod 755 /etc/systemd/system/$odoo_name.service
sudo chown root: /etc/systemd/system/$odoo_name.service

sudo systemctl daemon-reload
sudo systemctl start $odoo_name.service
sudo systemctl enable $odoo_name.service

sudo systemctl status $odoo_name
