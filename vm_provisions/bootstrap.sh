#!/usr/bin/env bash


# Pre-Configuration Variables
# ---------------------------------------------------------------------- */
MAGE_VERSION=$1
DATA_VERSION=$2
SAMPLE_DATA=$3

ADMIN_USER=$4
ADMIN_PASS=$5

DB_USER=$6
DB_PASS=$7
DB_NAME=$8
MAGENTO_URL=$9

MAGERUN=${10}
MODMAN=${11}
GIT=${12}
COMPASS=${13}
RVM_VERSION${14}


# Run update
# ---------------------------------------------------------------------- */
apt-get update


# Install Apache & PHP
# ---------------------------------------------------------------------- */
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysqlnd php5-curl php5-xdebug php5-gd php5-intl php-pear php5-imap php5-mcrypt php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-soap memcached
# mycrypt sometimes doesn't add itself to php's module list. The following line ensures that it does
php5enmod mcrypt


# Delete default apache web dir and symlink mounted vagrant dir from host machine
# ---------------------------------------------------------------------- */
rm -rf /var/www/html
mkdir /vagrant/httpdocs
ln -fs /vagrant/httpdocs /var/www/html


# Replace contents of default Apache vhost
# ---------------------------------------------------------------------- */
VHOST=$(cat <<EOF
NameVirtualHost *:8080
Listen 8080
<VirtualHost *:80>
  DocumentRoot "/var/www/html"
  ServerName localhost
  <Directory "/var/www/html">
    AllowOverride All
  </Directory>
</VirtualHost>
<VirtualHost *:8080>
  DocumentRoot "/var/www/html"
  ServerName localhost
  <Directory "/var/www/html">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "$VHOST" > /etc/apache2/sites-enabled/000-default.conf

a2enmod rewrite
service apache2 restart


# Setup MySQL Database for Magento
# ---------------------------------------------------------------------- */
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
apt-get -q -y install mysql-server-5.5
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'"
mysql -u root -e "FLUSH PRIVILEGES"


# Download Magento
# ---------------------------------------------------------------------- */
# http://www.magentocommerce.com/wiki/1_-_installation_and_configuration/installing_magento_via_shell_ssh
# Download and extract
if [[ ! -f "/vagrant/httpdocs/index.php" ]]; then
  cd /vagrant
  if [[ ! -f "/vagrant/magento-${MAGE_VERSION}.tar.gz" ]]; then
    # Only download magento if we need to
    wget http://www.magentocommerce.com/downloads/assets/${MAGE_VERSION}/magento-${MAGE_VERSION}.tar.gz
  fi
  tar -zxvf magento-${MAGE_VERSION}.tar.gz -C /vagrant/httpdocs/
  cd /vagrant/httpdocs
  mv magento/* magento/.htaccess .
  chmod -R o+w media var
  chmod o+w app/etc
  # Clean up downloaded file and extracted dir
  rm -rf magento*
fi


# Download and Install Sample Data
# ---------------------------------------------------------------------- */
if [[ $SAMPLE_DATA == "true" ]]; then
  cd /vagrant
  if [[ ! -f "/vagrant/magento-sample-data-${DATA_VERSION}.tar.gz" ]]; then
    # Only download sample data if we need to
    wget http://www.magentocommerce.com/downloads/assets/${DATA_VERSION}/magento-sample-data-${DATA_VERSION}.tar.gz
  fi
  tar -zxvf magento-sample-data-${DATA_VERSION}.tar.gz
  cp -R magento-sample-data-${DATA_VERSION}/media/* httpdocs/media/
  cp -R magento-sample-data-${DATA_VERSION}/skin/*  httpdocs/skin/
  mysql -u root ${DB_NAME} < magento-sample-data-${DATA_VERSION}/magento_sample_data_for_${DATA_VERSION}.sql
  rm -rf magento-sample-data-${DATA_VERSION}
fi


# Run the Magento Installer
# ---------------------------------------------------------------------- */
if [ ! -f "/vagrant/httpdocs/app/etc/local.xml" ]; then
  cd /vagrant/httpdocs
  sudo /usr/bin/php -f install.php -- \
  --license_agreement_accepted "yes" \
  --locale "en_US" \
  --timezone "America/Los_Angeles" \
  --default_currency "USD" \
  --db_host "localhost" \
  --db_name ${DB_NAME} \
  --db_user ${DB_USER} \
  --db_pass ${DB_PASS} \
  --url ${MAGENTO_URL} \
  --use_rewrites "yes" \
  --use_secure "no" \
  --secure_base_url ${MAGENTO_URL} \
  --use_secure_admin "no" \
  --skip_url_validation "yes" \
  --admin_lastname "Owner" \
  --admin_firstname "Store" \
  --admin_email "admin@example.com" \
  --admin_username ${ADMIN_USER} \
  --admin_password ${ADMIN_PASS}
  /usr/bin/php -f shell/indexer.php reindexall
fi


# Install n98-magerun
# ---------------------------------------------------------------------- */
if [[ $MAGERUN == "true" ]]; then
  cd /vagrant
  if [[ ! -f "n98-magerun.phar" ]]; then
    wget http://files.magerun.net/n98-magerun-latest.phar -O n98-magerun.phar
  fi
  sudo cp ./n98-magerun.phar /usr/bin/magerun
  sudo chmod +x /usr/bin/magerun
fi


# Install Modman
# ---------------------------------------------------------------------- */
if [[ $MODMAN == "true" ]]; then
  cd /vagrant
  sudo bash < <(wget -q --no-check-certificate -O - https://raw.github.com/colinmollenhour/modman/master/modman-installer)
  sudo mv /root/bin/modman /usr/bin/
  sudo chmod +x /usr/bin/modman
fi


# Install Compass (RVM + SASS)
# ---------------------------------------------------------------------- */
if [[ $COMPASS == "true" ]]; then
  cd /vagrant
  sudo curl -L http://get.rvm.io | bash -s
  source /home/vagrant/.rvm/scripts/rvm
  rvm use --install ${RVM_VERSION}
  gem update --system
  gem install compass
fi


# Install Git and a standard magento .gitignore file
# ---------------------------------------------------------------------- */
if [[ $GIT == "true" ]]; then
  apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev
  apt-get install -y git
  cd /var/www/html/
  if [[ ! -f "/var/www/html/.gitignore" ]]; then
    wget https://raw.githubusercontent.com/github/gitignore/master/Magento.gitignore -O Magento.gitignore
    mv Magento.gitignore .gitignore
  fi
fi

# Print Completion Message
# ---------------------------------------------------------------------- */
echo "+++++++++++++++++++++++++++++++++++++++++++++++++"
echo "++++++++ URL: ${MAGENTO_URL} ++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++"