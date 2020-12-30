#!/bin/bash
clear

#makes sure root ain't running this
if [ "$EUID" -eq 0 ]; then
	echo "Please don't run this as root."
	exit
fi

#function that makes sure the previous command worked.
check_status () {
	if [ $? != "0" ]; then
        	echo "something didn't work."
        	exit
	fi
}

#CHANGE THESE TO DOWNLOAD/INSTALL TOR SOMEWHERE ELSE.

#where the script downloads tor.
assets_d=~/Downloads
#where the script installs tor.
install_d=~/.tor-browser

#checks for existing installs.

cd ~
if [[ -d $install_d || -f ~/.local/share/applications/start-tor-browser.desktop ]]; then
	echo "tor's already been installed. [r]einstall, [u]ninstall or [c]ancel?"
	read input
	if [[ $input == "U" || $input == "u" ]]; then
		echo "uninstalling."
		rm -rf $install_d
		rm -f ~/.local/share/applications/start-tor-browser.desktop
		echo "finished"
		exit
	elif [[ $input == "R" || $input == "r" ]]; then
		rm -rf $install_d
		rm -f ~/.local/share/applications/start-tor-browser.desktop
		rm -f $assets_d/tor-browser-linux-*.*_en-US.tar.xz
		rm -f $assets_d/tor-browser-linux-*.*_en-US.tar.xz.asc
		echo "old install removed."
	elif [[ $input == "c" || $input == "C" ]]; then
		echo "exiting."
		exit
	else
		echo "invalid input, exiting."
		exit
	fi
fi

#downloads. comment out this stuff and change $assets_d to use existing files.

echo "installing tor."
cd $assets_d
echo "input latest version number. [find it at https://torproject.org]"
read version
wget https://www.torproject.org/dist/torbrowser/"$version"/tor-browser-linux64-"$version"_en-US.tar.xz -q --show-progress
check_status
wget https://www.torproject.org/dist/torbrowser/"$version"/tor-browser-linux64-"$version"_en-US.tar.xz.asc -q --show-progress
check_status

#verifies. this is very important.

cd ~
gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
check_status
rm -f ~/tor.keyring
gpg --output ~/tor.keyring --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290
gpgv --keyring ~/tor.keyring $assets_d/tor-browser-linux64-*.*_en-US.tar.xz.asc $assets_d/tor-browser-linux64-*.*_en-US.tar.xz
check_status

#installs to whatever $install_d is set to.

mkdir $install_d
cd $assets_d
tar xf tor-browser-linux64-*.*_en-US.tar.xz -C $install_d
check_status
cd $install_d/tor-browser_en-US
./start-tor-browser.desktop --register-app > /dev/null
echo "finished."
exit
