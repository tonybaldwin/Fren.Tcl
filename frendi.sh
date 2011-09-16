#!/bin/bash

# update friendika from bash with curl
# I put this in my path as "frendi"

# here you enter your username and password
# and other relevant variables, such as whether or not
# you'd like to cross post to statusnet, twitter, or farcebork

read -p "Please enter your username: " uname
read -p "Please enter your password: " pwrd
read -p "Cross post to statusnet? (1=yes, 0=no): " snet
read -p "Cross post to twitter? (1=yes, 0=no): " twit
read -p "Cross post to Farcebork? (1=yes, 0=no): " fb
read -p "Enter the domain of your Friendika site (i.e. http://friendika.somesite.net): " url

# if you did not enter text for update, the script asks for it

if [[ $(echo $*) ]]; then
	ud="$*"
else
	read -p "Enter your update text: " ud
fi

# and this is the curl command that sends the update to the server

if [[ $(curl -u $uname:$pwrd  -d "status=$ud&statusnet_enable=$snet&twitter_enable=$twit&facebook_enable=$fb"  $url/api/statuses/update.xml | grep error) ]]; then

# what does the server say?

	echo "Error"
else 
	echo "Success!"
	echo $ud
fi
