#!/bin/bash

#Bash script to create new user, set webroot and vhost

ROOT_UID=0
SUCCESS=0
E_USEREXISTS=70



if [ $# -eq 3 ]; then
	username=$1
	pass=$2
	domain=$3
	email=""
	webroot="/home/$username/public_html"


#Check if username is used and create user

	grep -q  "$username" /etc/passwd
	if [ ! $? -eq $SUCCESS ]; then
		echo "User $username doesnt exist, creating new user."
		useradd -p `mkpasswd "$pass"` -d /home/"$username" -m -g users -s /bin/bash "$username"
		useradd -p $username $username
		usermod -aG www-data $username
		usermod -aG sudo $username
		echo "User has been created"
	fi

#Create webroot to home dir

	if [ ! -d "$webroot" ]; then
		echo " Creating $webroot"
		mkdir  -p $webroot
		chown root:root /home/$username/public_html
		chown -R www-data:www-data $webroot
			chmod -R 775 $webroot
	fi
	echo "Creating Virtualhost"

#Create Virtualhost

	if [ -f /etc/apache2/sites-available/template.conf ]; then

		sudo cp /etc/apache2/sites-available/template.conf /etc/apache2/sites-available/$domain.conf
		sudo sed -i 's/example.url/'$domain'/g' /etc/apache2/sites-available/$domain.conf
		sudo sed -i 's#example.webroot#'$webroot'#g' /etc/apache2/sites-available/$domain.conf

		echo "Add domain to /etc/hosts"
		sudo sed -i '1s/^/127.0.0.1	'$domain'\n/' /etc/hosts
		sudo a2ensite $domain
		sudo service apache2 reload
		echo "Virtualhost created with webroot $webroot"
	else
		echo "Cant find conf template file"
		exit

	fi

else
	echo "Something went wrong"
fi

#Dont print password for security reasons

echo  "Credentials: $username , Domain: $domain "

exit 0
