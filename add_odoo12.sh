#!/bin/bash

echo "******************************************************"
echo "ADD NEW ODOO 12 INSTANCE"
echo "******************************************************"

echo "******************************************************"
echo "CREATE DATABASE USER FOR ODOO"
echo "******************************************************"
echo "Quando solicitado use a senha padrão: bem-vindo"

sudo su postgres <<HERE
cd

createuser -d -P $odoo_name

HERE

echo "******************************************************"
echo "CREATE ODOO LOG FILE"
echo "******************************************************"

sudo mkdir /var/log/$odoo_name

sudo chown -R $odoo_name:root /var/log/$odoo_name

echo "******************************************************"
echo "EDIT ODOO CONFIGURATION FILE"
echo "******************************************************"

echo "[options]

; This is the password that allows database operations:

admin_passwd = admin

db_host = False

db_port = False

db_user = $odoo_name

db_password = bem-vindo

http_port = $odoo_port

logfile = /var/log/$odoo_name/odoo-server.log

addons_path = /opt/quantso/odoo_br/addons,/opt/quantso/odoo_br/odoo/addons,/opt/quantso/odoo_br/odoo-brasil" | sudo tee -a /etc/$odoo_name.conf

sudo chown $odoo_name: /etc/$odoo_name.conf

echo "******************************************************"
echo "MAKE AN ODOO SERVICE - START AND ENABLE IT"
echo "******************************************************"

echo "Edit Odoo server file"

echo "[Unit]
Description=$odoo_name
Requires=postgresql.service
After=network.target postgresql.service

[Service]
# Ubuntu/Debian convention:
Type=simple
User=$username
ExecStart=/opt/quantso/odoo_br/odoo-bin -c /etc/$odoo_name.conf
StandardOutput=journal+console

[Install]
WantedBy=default.target" | sudo tee -a /etc/systemd/system/$odoo_name.service

sudo chmod 755 /etc/systemd/system/$odoo_name.service
sudo chown root: /etc/systemd/system/$odoo_name.service

sudo systemctl daemon-reload
sudo systemctl start $odoo_name.service
sudo systemctl enable $odoo_name.service

sudo systemctl status $odoo_name