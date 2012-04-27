#!/bin/bash

##########################################################3
# This script will install fren.tcl on a gnu/linux system.
# If you're using BSD or Mac OS, I believe it should also work fine.
# If you are using Windows, I can't help you.
##########################################################3

name=$(whoami)

if [ != "$HOME/bin/" ]; then
	mkdir $HOME/bin/
	$PATH=$PATH:/$HOME/bin/
	export PATH
else

echo "Installing frentcl..."

echo "Creating config files..."

mkdir $HOME/.frentcl
cp frentcl.conf $HOME/.frentcl/

echo "Moving files, setting permissions..."

cp fren.tcl $HOME/bin/fren.tcl
chmod +x $HOME/bin/fren.tcl

echo "Installation complete!"
echo "To run fren.tcl, in terminal type fren.tcl, or make an icon/menu item/short cut to /home/$name/bin/fren.tcl"
echo "Don't forget to edit preferences before trying to post for the first time! "
echo "Enjoy!"

fi
exit
