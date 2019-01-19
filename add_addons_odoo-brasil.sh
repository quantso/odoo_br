#!/bin/bash

customer=""

echo "What's the customer's name or id? (odoo_name = odoo<customer name>"

read customer

odoo_name="odoo$customer"


echo "******************************************************"
echo "INSTALL PYTHON DEPENDENCIES FOR ODOO-BRASIL"
echo "******************************************************"

sudo apt-get install -y libxmlsec1-dev pkg-config libffi-dev

echo "******************************************************"
echo "INSTALL ALL ODOO-BRASIL REQUIREMENTS"
echo "******************************************************"

pip3 install -r /opt/quantso/odoo_br/odoo-brasil/requirements.txt

cd /opt/quantso/odoo_br/py-pkgs/PyTrustNFe

python3 setup.py install

echo "******************************************************"
echo "EDIT ODOO CONFIGURATION FILE"
echo "******************************************************"

addons_path

nrow=$(sudo awk '/addons_path/{ print NR; exit }' /etc/$odoo_name.conf)

eval "sudo sed -i '${nrow}s/$/,/opt/quantso/odoo_br//' /etc/$odoo_name.conf"



echo "******************************************************"
echo "RESTART ODOO SERVICE"
echo "******************************************************"

sudo systemctl daemon-reload
sudo systemctl start $odoo_name.service
sudo systemctl enable $odoo_name.service

sudo systemctl status $odoo_name