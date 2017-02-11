#!bin/bash

# Tech and Me ©2016 - www.techandme.se

WPPATH=/var/www/html/wordpress
ADDRESS=$(hostname -I | cut -d ' ' -f 1)
dir_before_letsencrypt=/etc
letsencryptpath=/etc/letsencrypt
certfiles=$letsencryptpath/live
ssl_conf="/etc/apache2/sites-available/default-ssl.conf"
scripts_dir=/var/scripts

# Check if root
if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou need to type: \e[36msudo \e[0mbash /var/scripts/activate-ssl.sh"
        echo
exit 1
fi

clear

cat << STARTMSG
+---------------------------------------------------------------+
|       Important! Please read this!                            |
|                                                               |
|       This script will install SSL from Let's Encrypt.        |
|       It's free of charge, and very easy to use.              |
|                                                               |
|       Before we begin the installation you need to have       |
|       a domain that the SSL certs will be valid for.          |
|       If you don't have a domian yet, get one before          |
|       you run this script!                                    |
|								|
|       You also have to open port 443 against this VMs         |
|       IP address: $ADDRESS - do this in your router.  |
|       Here is a guide: https://goo.gl/Uyuf65                  |
|                                                               |
|       This script is located in /var/scripts and you          |
|       can run this script after you got a domain.             |
|                                                               |
|       Please don't run this script if you don't have		|
|       a domain yet. You can get one for a fair price here:	|
|       https://www.citysites.eu/                               |
|                                                               |
+---------------------------------------------------------------+

STARTMSG

	function ask_yes_or_no() {
    	read -p "$1 ([y]es or [N]o): "
    	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "no" == $(ask_yes_or_no "Are you sure you want to continue?") ]]
then
	echo
    	echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/activate-ssl.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
exit
fi

        function ask_yes_or_no() {
        read -p "$1 ([y]es or [N]o): "
        case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "no" == $(ask_yes_or_no "Have you forwarded port 443 in your router?") ]]
then
        echo
        echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/activate-ssl.sh"
        echo -e "\e[32m"
        read -p "Press any key to continue... " -n1 -s
        echo -e "\e[0m"
exit
fi

    	function ask_yes_or_no() {
    	read -p "$1 ([y]es or [N]o): "
    	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
	*)     echo "no" ;;
	esac
}
if [[ "yes" == $(ask_yes_or_no "Do you have a domian that you will use?") ]]
then
        sleep 1
else
	echo
    	echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/activate-ssl.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
exit
fi

# Install git
	git --version 2>&1 >/dev/null
	GIT_IS_AVAILABLE=$?
# ...
	if [ $GIT_IS_AVAILABLE -eq 1 ]; then
        sleep 1
else
        apt-get install git -y -q
fi

# Fetch latest version of test-new-config.sh
scripts_dir=/var/scripts

if [ -f $scripts_dir/test-new-config.sh ];
then
        rm $scripts_dir/test-new-config.sh
        wget https://raw.githubusercontent.com/enoch85/ownCloud-VM/master/lets-encrypt/test-new-config.sh -P $scripts_dir
        chmod +x $scripts_dir/test-new-config.sh
else
        wget https://raw.githubusercontent.com/enoch85/ownCloud-VM/master/lets-encrypt/test-new-config.sh -P $scripts_dir
        chmod +x $scripts_dir/test-new-config.sh
fi

# Check if $ssl_conf exits, and if, then delete
if [ -f $ssl_conf ];
then
        rm $ssl_conf
fi
echo
# Ask for domain name
cat << ENTERDOMAIN
+---------------------------------------------------------------+
|    Please enter the domain name you will use for ownCloud:	|
|    Like this: example.com, or owncloud.example.com (1/2)	|
+---------------------------------------------------------------+
ENTERDOMAIN
	echo
	read domain

	function ask_yes_or_no() {
    	read -p "$1 ([y]es or [N]o): "
    	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    	esac
}
echo
if [[ "no" == $(ask_yes_or_no "Is this correct? $domain") ]]
	then
echo
echo
cat << ENTERDOMAIN2
+---------------------------------------------------------------+
|    OK, try again. (2/2) 					|
|    Please enter the domain name you will use for ownCloud:	|
|    Like this: example.com, or owncloud.example.com		|
|    It's important that it's correct, because the script is 	|
|    based on what you enter					|
+---------------------------------------------------------------+
ENTERDOMAIN2

	echo
    	read domain
    	echo
fi

# Change ServerName in apache.conf
sed -i "s|ServerName owncloud|ServerName $domain|g" /etc/apache2/apache2.conf

# Generate owncloud_ssl_domain.conf
if [ -f $ssl_conf ];
	then
        echo "Virtual Host exists"
else
	touch "$ssl_conf"
	echo "$ssl_conf was successfully created"
	sleep 3
	cat << SSL_CREATE > "$ssl_conf"
<VirtualHost *:443>

    Header add Strict-Transport-Security: "max-age=15768000;includeSubdomains"
    SSLEngine on

### YOUR SERVER ADDRESS ###

    ServerAdmin admin@$domain
    ServerName $domain

### SETTINGS ###

    DocumentRoot $WPPATH

    <Directory $WPPATH>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    Satisfy Any
    </Directory>
    SetEnv HOME $WPPATH
    SetEnv HTTP_HOME $WPPATH


### LOCATION OF CERT FILES ###

    SSLCertificateChainFile $certfiles/$domain/chain.pem
    SSLCertificateFile $certfiles/$domain/cert.pem
    SSLCertificateKeyFile $certfiles/$domain/privkey.pem

</VirtualHost>
SSL_CREATE
fi

##### START FIRST TRY

# Stop Apache to avoid port conflicts
        a2dissite 000-default.conf
        sudo service apache2 stop
# Check if $letsencryptpath exist, and if, then delete.
if [ -d "$letsencryptpath" ]; then
  	rm -R $letsencryptpath
fi
# Generate certs
	cd $dir_before_letsencrypt
	git clone https://github.com/letsencrypt/letsencrypt
	cd $letsencryptpath
        ./letsencrypt-auto certonly --standalone -d $domain
# Use for testing
#./letsencrypt-auto --apache --server https://acme-staging.api.letsencrypt.org/directory -d EXAMPLE.COM
# Activate Apache again (Disabled during standalone)
        service apache2 start
        a2ensite 000-default.conf
        service apache2 reload
# Check if $certfiles exists
if [ -d "$certfiles" ]; then
# Activate new config
        bash /var/scripts/test-new-config.sh
	exit 0
else
        echo -e "\e[96m"
        echo -e "It seems like no certs were generated, we do three more tries."
        echo -e "\e[32m"
        read -p "Press any key to continue... " -n1 -s
        echo -e "\e[0m"
fi
##### START SECOND TRY

# Check if $letsencryptpath exist, and if, then delete.
	if [ -d "$letsencryptpath" ]; then
  	rm -R $letsencryptpath
fi
# Generate certs
	cd $dir_before_letsencrypt
	git clone https://github.com/letsencrypt/letsencrypt
	cd $letsencryptpath
	./letsencrypt-auto -d $domain
# Check if $certfiles exists
if [ -d "$certfiles" ]; then
# Activate new config
	bash /var/scripts/test-new-config.sh
        exit 0
else
	echo -e "\e[96m"
	echo -e "It seems like no certs were generated, we do two more tries."
	echo -e "\e[32m"
	read -p "Press any key to continue... " -n1 -s
	echo -e "\e[0m"
fi
##### START THIRD TRY

# Check if $letsencryptpath exist, and if, then delete.
if [ -d "$letsencryptpath" ]; then
  	rm -R $letsencryptpath
fi
# Generate certs
	cd $dir_before_letsencrypt
	git clone https://github.com/letsencrypt/letsencrypt
	cd $letsencryptpath
	./letsencrypt-auto certonly --agree-tos --webroot -w $WPPATH -d $domain
# Check if $certfiles exists
if [ -d "$certfiles" ]; then
# Activate new config
        bash /var/scripts/test-new-config.sh
        exit 0

else
        echo -e "\e[96m"
        echo -e "It seems like no certs were generated, we do one more try."
        echo -e "\e[32m"
        read -p "Press any key to continue... " -n1 -s
        echo -e "\e[0m"
fi
#### START FORTH TRY

# Check if $letsencryptpath exist, and if, then delete.
if [ -d "$letsencryptpath" ]; then
  	rm -R $letsencryptpath
fi
# Generate certs
	cd $dir_before_letsencrypt
	git clone https://github.com/letsencrypt/letsencrypt
	cd $letsencryptpath
        ./letsencrypt-auto --agree-tos --apache -d $domain
# Check if $certfiles exists
if [ -d "$certfiles" ]; then
# Activate new config
        bash /var/scripts/test-new-config.sh

        exit 0
else
        echo -e "\e[96m"
        echo -e "Sorry, last try failed as well. :/ "
        echo -e "\e[0m"
cat << ENDMSG
+-----------------------------------------------------------------------+
| The script is located in /var/scripts/activate-ssl.sh                 |
| Please try to run it again some other time with other settings.       |
|                                                                       |
| There are different configs you can try in Let's Encrypts user guide: |
| https://letsencrypt.readthedocs.org/en/latest/index.html              |
| Please check the guide for further information on how to enable SSL.  |
|                                                                       |
| This script is developed on GitHub, feel free to contribute:          |
| https://github.com/enoch85/ownCloud-VM/                               |
|                                                                       |
| The script will now do some cleanup and revert the settings.          |
+-----------------------------------------------------------------------+
ENDMSG
        echo -e "\e[32m"
        read -p "Press any key to revert settings and exit... " -n1 -s
        echo -e "\e[0m"

# Cleanup
	rm -R $letsencryptpath
	rm $scripts_dir/test-new-config.sh
	rm $ssl_conf
	rm -R /root/.local/share/letsencrypt
# Change ServerName in apache.conf
	sed -i "s|ServerName|#ServerName|g" /etc/apache2/apache2.conf
	echo "ServerName $domain" >> /etc/apache2/apache2.conf
fi
clear
