#!/bin/bash

# update friendica with bash, vim and curl
# I put this in my path as "friendi.sh"
# by tony baldwn, http://tonybaldwin.me
# on friendica at http://free-haven.org/profile/tony
# released according to the Gnu Public License, v.3

# first, create a post/update

filedate=$(date +%m%d%y%H%M%S)

# if you did not enter text for update, the script asks for it

if [[ $(echo $*) ]]; then
	ud="$*"
else
	vim $filedate.fpost
	ud=$(cat $filedate.fpost)
fi

read -p "Please enter a title: " title

# now to see if you want to crosspost elsewhere
echo "For the following question regarding crossposting, please enter the number 1 for yes, and 0 for no."
echo "If your friendica has the plugins, and you've configured them, you can crosspost to other blogs and sites."
echo "friendica will even automatically change the bbcode to proper html for you."
echo "would you like to crosspost to "
read -p "statusnet? " snet
read -p "twitter? " twit
read -p "facebook? " fb
read -p "dreamwidth?  " dw
read -p "livejournal? " lj
read -p "insanejournal?" ij
read -p "tumblr? " tum
read -p "posterous? " pos
read -p "wordpress? " wp 

# now to authenticate
read -p "Please enter your username: " uname
read -p "Please enter your password: " pwrd
read -p "Enter the domain of your Friendica site (i.e. http://friendica.somesite.net): " url

# and this is the curl command that sends the update to the server

if [[ $(curl -u -k $uname:$pwrd  -d "status=$ud&title=$title&ijpost_enable=$ij&ljpost_enable=$lj&posterous_enable=$pos&dwpost_enable=$dw&wppost_enable=$wp&tumblr_enable=$tum&facebook_enable=$fb&twitter_enable=$twit&statusnet_enable=$snet&source=friendi.sh"  $url/api/statuses/update.xml | grep error) ]]; then

# what does the server say?

	echo "Error"
else 
	echo "Success!"
	echo $ud
fi
