#!/bin/bash

echo "******************************************************"
echo "START ODOO 12 INSTALL"
echo "******************************************************"

echo "Update apt source list"

sudo apt-get update

echo "Install Updates"

sudo apt-get -y upgrade

echo "******************************************************"
echo "INSTALL PYTHON DEPENDENCIES FOR ODOO 12"
echo "******************************************************"

sudo apt install python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt1-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less -y

echo "******************************************************"
echo "INSTALL DEPENDENCIES USING PIP3"
echo "******************************************************"

pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd

echo "******************************************************"
echo "ODOO WEB DEPENDENCIES"
echo "******************************************************"

sudo apt-get install -y npm

echo "Just in case it doesn't exist yet"
sudo ln -s /usr/bin/nodejs /usr/bin/node

sudo npm install -g less less-plugin-clean-css

sudo apt-get install node-less -y

sudo python3 -m pip install libsass

echo "******************************************************"
echo "INSTALL PostgreSQL 9.6+"
echo "******************************************************"

sudo apt-get install python3-software-properties

echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install postgresql-9.6 -y

echo "******************************************************"
echo "CONFIGURING POSTGRES AUTHENTICATION"
echo "******************************************************"

nrow=$(sudo awk '/"local" is for Unix domain socket connections only/{ print NR; exit }' /etc/postgresql/9.6/main/pg_hba.conf)
nrow=$(($nrow + 1))

eval "sudo sed -i '${nrow}s/peer/md5/' /etc/postgresql/9.6/main/pg_hba.conf"

sudo service postgres restart

echo "******************************************************"
echo "CREATE DATABASE USER FOR ODOO"
echo "******************************************************"
echo "Quando solicitado use a senha padrão: bem-vindo"

sudo su postgres <<HERE
cd

createuser -s quantso

createuser -d -P $odoo_name

HERE

echo "******************************************************"
echo "INSTALL GDATA"
echo "******************************************************"

cd /opt/quantso

sudo wget https://pypi.python.org/packages/a8/70/bd554151443fe9e89d9a934a7891aaffc63b9cb5c7d608972919a002c03c/gdata-2.0.18.tar.gz

sudo tar zxvf gdata-2.0.18.tar.gz

sudo chown -R quantso: gdata-2.0.18

sudo -s <<HERE
cd gdata-2.0.18/

sudo python setup.py install
HERE

echo "******************************************************"
echo "CREATE ODOO LOG FILE"
echo "******************************************************"

sudo mkdir /var/log/$odoo_name

sudo chown -R quantso:root /var/log/$odoo_name

echo "******************************************************"
echo "EDIT ODOO CONFIGURATION FILE"
echo "******************************************************"

echo "[options]

; This is the password that allows database operations:

admin_passwd = admin

db_host = False

db_port = False

db_user = $odoo_name

db_password = $password

http_port = $odoo_port

logfile = /var/log/$odoo_name/odoo-server.log

addons_path = /opt/quantso/odoo_br/addons,/opt/quantso/odoo_br/odoo/addons" | sudo tee -a /etc/$odoo_name.conf

sudo chown quantso: /etc/$odoo_name.conf

echo "******************************************************"
echo "WKHTMLTOPDF ( Supported Version 0.12.1 ) FOR ODOO"
echo "******************************************************"

sudo wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb

sudo apt install ./wkhtmltox_0.12.1.3-1~bionic_amd64.deb -y

sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage

sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf

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
