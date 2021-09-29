#!/bin/bash

# # Update
sudo apt update

# # Install Libraries
sudo apt-get install apache2-utils
sudo apt-get install sed

# Set & Check User

userCheck=1

while [ $userCheck -eq "1" ];      
do 
        echo -e 'Please enter username'
        read username
        userCheck=`grep -cim1 $username /etc/apache2/.htpasswd`
if [ $userCheck -eq "1" ] 
then
        echo 'This username already exists - please choose another.'
        continue
else  
        echo "User '${username}' has been created."
        sudo htpasswd -c /etc/apache2/.htpasswd $username
        userCheck=0
        echo $userCheck
        
fi
done

# Edit Nginx Configuration
if grep -q auth_basic /etc/nginx/sites-enabled/default;
then
    echo 'It looks like your NGINX confiugration already contains the relevant directives. Skipping...'
else
    sudo sed -i 's@location / {@location / {   \n  auth_basic "Server Administration";   \n  auth_basic_user_file /etc/apache2/.htpasswd; @g' /etc/nginx/sites-enabled/default
fi

# Gracefully Restart 
echo 'Would you like to restart NGINX now? [Y/N] Please note that the changes will not take effect until a restart has occured.'
read answer 
sudo nginx -t > /dev/null 2>&1
checkNginx=`echo $?`
if [[ $answer -eq "Y" ]] || [[ $answer -eq "y" ]] && [ $checkNginx -eq 0 ];
then  
    sudo service nginx restart
    echo "NGINX has been restarted"
    sudo service nginx status
else
    echo 'Nginx has not been restarted'
fi
