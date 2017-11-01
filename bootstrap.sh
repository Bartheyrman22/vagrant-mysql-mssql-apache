#!/usr/bin/env bash

apt-get update

printf "\nInstalling htop...\n\n"

apt-get install -y -q htop

printf "\Installing Apache2...\n\n"

apt-get install -y -q apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant/repositories /var/www
fi

printf "\nInstalling MySQL...\n\n"

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y -q mysql-server
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -proot --execute "CREATE USER 'root'@'%' IDENTIFIED BY 'root';"
mysql -u root -proot --execute "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' with GRANT OPTION; FLUSH PRIVILEGES;"
mysql -u root -proot --execute "DROP USER 'root'@'localhost';"

printf "\nInstalling MSSQL...\n\n"

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server.list | tee /etc/apt/sources.list.d/mssql-server.list
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
apt-get update
apt-get install -y -q mssql-server
export ACCEPT_EULA=y
apt-get install -y -q mssql-tools unixodbc-dev
MSSQL_SA_PASSWORD='Administrator01'
MSSQL_PID='express'
/opt/mssql/bin/mssql-conf setup
/opt/mssql/bin/mssql-conf set telemetry.customerfeedback false

systemctl stop mssql-server
systemctl start mssql-server
systemctl status mssql-server

printf "\nBootstrap: DONE\n\n"