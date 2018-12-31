#!/bin/bash

echo "Update apt source list"

sudo apt-get update

echo "Install Updates"

sudo apt-get -y upgrade

echo "Install Python Dependencies for Odoo 12"

sudo apt install python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt1-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libffi-dev -y

echo "INSTALL DEPENDENCIES USING PIP3"
pip3 install Babel decorator docutils ebaysdk feedparser gevent greenlet html2text Jinja2 lxml Mako MarkupSafe mock num2words ofxparse passlib Pillow psutil psycogreen psycopg2 pydot pyparsing PyPDF2 pyserial python-dateutil python-openid pytz pyusb PyYAML qrcode reportlab requests six suds-jurko vatnumber vobject Werkzeug XlsxWriter xlwt xlrd

echo "Install Python Dependencies for odoo-brasil"

sudo apt-get install -y libxmlsec1-dev pkg-config

echo "Odoo Web Dependencies"

sudo apt-get install -y npm

echo "Just in case it doesn't exist yet"
sudo ln -s /usr/bin/nodejs /usr/bin/node

sudo npm install -g less less-plugin-clean-css

sudo apt-get install node-less

sudo python3 -m pip install libsass


echo "Install PostgreSQL 9.6+"

sudo apt-get install python3-software-properties

echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install postgresql-9.6 -y


echo "Create Database user for Odoo"

echo "Case doesn't work run it: sudo su - postgres -c 'createuser -s odoo'"
sudo su postgres <<HERE
cd

createuser -s $odoo_name

createuser -s $username
HERE

echo "Install Gdata"

cd /opt/$odoo_name

sudo wget https://pypi.python.org/packages/a8/70/bd554151443fe9e89d9a934a7891aaffc63b9cb5c7d608972919a002c03c/gdata-2.0.18.tar.gz

sudo tar zxvf gdata-2.0.18.tar.gz

sudo chown -R $odoo_name: gdata-2.0.18

sudo -s <<HERE
cd gdata-2.0.18/

sudo python setup.py install
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


echo "WKHTMLTOPDF ( Supported Version 0.12.1 ) for Odoo"

sudo wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb

sudo apt install ./wkhtmltox_0.12.1.3-1~bionic_amd64.deb -y

sudo cp /usr/local/bin/wkhtmltoimage /usr/bin/wkhtmltoimage

sudo cp /usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf


echo "Installing all odoo-brasil requirements"

pip3 install -r /opt/$odoo_name/odoo_br/odoo-brasil/requirements.txt

cd /opt/$odoo_name/odoo_br/py-pkgs/PyTrustNFe

python3 setup.py install


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
