#!/bin/bash


SENHA_ROOT='R4F4$ants'
dropbox_64_fedora="https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2019.02.14-1.fedora.x86_64.rpm"
dropbox_64_fedora_rpm=$(echo $dropbox_64_fedora | cut -d"/" -f6)
dropbox_32_fedora="https://www.dropbox.com/download?dl=packages/fedora/nautilus-dropbox-2019.02.14-1.fedora.i386.rpm"
dropbox_32_fedora_rpm=$(echo $dropbox_32_fedora | cut -d"/" -f6)
dropbox_64_debian="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2019.02.14_amd64.deb"
dropbox_64_debian_deb=$(echo $dropbox_64_debian | cut -d"/" -f6)
dropbox_32_debian="https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2019.02.14_i386.deb"
dropbox_32_debian_deb=$(echo $dropbox_32_debian | cut -d"/" -f6)

#############################################################################################
####################              AUTHOR: RAFAEL SANTOS                  ####################
########	      This script makes my basics Linux configurations.              ########
#####             Like: Install some Packages, update system based on DIST              #####
###                    		  and edit some Config Files.                             ###
## 											   ##
###					./configura.sh					  ###
####                                			                                #####
########		        	     v1.1				     ########
####################                                                     ####################
#############################################################################################
	
	if [ ! $UID -eq 0 ]
	then
		echo "You must be root!"
		exit 1
	fi

	reset


	echo "====================================="
	echo "Running $0 as root."
	echo "Made by Rafael Santos"
	echo "Distro: $(cat /etc/*-release 2> /dev/null | grep "PRETTY_NAME" | sed -e 's/.*=//' | tr -d '"') ($(uname -p))"
	echo "====================================="
	echo
	echo

## Checando conexão com Internet

	echo
	echo "## Checking Network Connection ..."

	if ping -qc 3 8.8.8.8 &> /dev/null
	then
		echo "Connected!"
		sleep 2
	else
		echo "Not Connected, ABORTED!"
		exit 1
	fi

	echo
	echo "#############################################"
	echo

	echo "## Detecting Distribution ..."
	sleep 1

if [ -f /etc/redhat-release ]
then
	DIST=REDHAT
	echo "Derived DIST $DIST: $(cat /etc/*-release 2> /dev/null | grep "PRETTY_NAME" | sed -e 's/.*=//')"
	echo
	sleep 1
else
	DIST=DEBIAN
	echo "Derived DIST $DIST: $(cat /etc/*-release 2> /dev/null | grep "PRETTY_NAME" | sed -e 's/.*=//')"
	echo
	sleep 1
fi
	echo "## Detecting ARCH ..."
	sleep 2

	if uname -m | grep 64 > /dev/null
	then
		ARCH="64"
		echo "Arch: $ARCH"
	else
		ARCH="x86"
		echo "Arch: $ARCH"
	fi

	echo
	echo "Done!"
	echo "#############################################"
	echo
	sleep 2

## CONFIGURA SUDOERS PARA NAO PEDIR SENHA

	read -p "What's your Username? " USUARIO

	until egrep -qo "^$USUARIO\b" /etc/passwd
	do
		echo "Invalid Username!"
		read -p "What's your Username? " USUARIO
	done

	echo
	sleep 1
	echo "Validated User: $USUARIO"

	echo
	echo "## Editing sudoers File ..."
	echo
	sleep 2
	
	echo "" >> /etc/sudoers  || echo "Error, please do it manually!"
	echo "$USUARIO ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || echo "Error, please do it manually!"
	echo "Done!"
	sleep 2
	
	echo "# Adding $USUARIO to root group ..."
	sleep 1
	usermod -G root $USUARIO || echo "Error, please do it manually!"
	echo "Done!"
		
	echo
	echo "#############################################"
	sleep 2



## ATUALIZA SISTEMA

echo

if [ $DIST = "DEBIAN" ]
then
	echo "## System Upgrading..."
	echo
	sleep 1

	echo "#Adding homebank repository ..."
	add-apt-repository ppa:mdoyen/homebank  || echo "Error, please do it manually!"
	echo

	echo "# Updating sources.list ..."
	apt update -y /dev/null || echo "Error, please do it manually!"

	apt upgrade -y > /dev/null || echo "Error, please do it manually!"
	apt clean > /dev/null || echo "Error, please do it manually!"
	apt autoclean > /dev/null || echo "Error, please do it manually!"

	echo
	echo "$DIST Updated!"
	sleep 1
	echo "Done!"
else
	echo "## Installing RPM Fusion Repository for FEDORA..."
	echo

	dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  > /dev/null || echo "Error, please do it manually!"

	echo "# System Upgrading..."
	dnf upgrade -y > /dev/null || echo "Error, please do it manually!"
	dnf clean packages > /dev/null || echo "Error, please do it manually!"

	echo
	echo "$DIST Updated!"
	sleep 1
	echo "Done!"
fi
 	echo
	echo "#############################################"
	echo

## INSTALA NUMLOCKX E CONFIGURA (SE DIST=REDHAT)

if [ $DIST = "REDHAT" ]
then
	echo
	echo "## Installing Numlockx ..."
	echo

	dnf install numlockx -y > /dev/null || echo "Error, please do it manually!"

	echo "# Configuring numlockx.desktop ..."
	sleep 1

	touch cd /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"
	echo -e "[Desktop Entry]\n\nVersion=0\nType=Application\nName=Numlockx\nDescription=Enable Numlock at boot\nExec=/usr/bin/numlockx on" > /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"
fi
	echo "Done!"
	echo
	echo "#############################################"

## CONFIGURA bashrc

	echo
	echo "## Configuring bashrc ..."
	sleep 1

	if [ -f /etc/bashrc ]
	then
		echo
		BASHRC="/etc/bashrc"
		echo "bashrc File: $BASHRC"
	else
		echo
		BASHRC="/etc/bash.bashrc"
		echo "bashrc File: $BASHRC"
	fi

	echo >> $BASHRC
	echo "#Terminal Utils (Rafael)" >> $BASHRC
	echo >> $BASHRC

	echo
	echo '# Configuring $PS1 ...'

	echo 'PS1="\[\033[1;33m\]❝ \u™\[\033[1;37m\] \[\033[0;33m\]@\[\033[1;37m\]  \[\033[1;32m\]\h\[\033[1;37m\] ❞  \[\033[1;3    1m\](( \W )) \[\033[7;36m\]\n \$ (\j BG PROCESS | \! IS YOUR COMMAND NUMBER) ➣ \[\033[0m\] "' >> $BASHRC || echo "Error, please do it manually!"
	echo >> $BASHRC
	sleep 1
	echo "# Configuring history command ..."

	echo "#Altera formato History, possibilita pesquisa por data" >> $BASHRC
	echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> $BASHRC || echo "Error, please do it manually!"
	echo >> $BASHRC
	sleep 1
	echo "# Configuring alias ..."
	
	echo "alias pv='pv -p -e -t -a -r'" >> $BASHRC || echo "Error, please do it manually!"

	echo
	echo "#############################################"

## CONFIGURA GRUB

	echo
	echo "## Configuring GRUB..."
	echo
	sleep 1

	echo "# Setting Network Interface to eth0 ..."
	sleep 1
	sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0"/' /etc/default/grub || echo "Error, please do it manually!"
	echo "# Removing Quit Splash ..."
	sleep 1
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=' /etc/default/grub || echo "Error, please do it manually!"

	echo "# Updating GRUB ..."
	echo

	grub2-mkconfig -o /boot/grub2/grub.cfg || grub-mkconfig -o /boot/grub/grub.cfg || echo "Error, please do it manually!"

	echo "Done!"
	echo
	echo "#############################################"

## ALTERA SENHA root

	echo
	echo "## Setting new password to root ..."
	sleep 1

	sudo usermod -p $(openssl passwd -1 $SENHA_ROOT) root || echo "Error, please do it manually!"

	echo "Done!"
	echo
	echo "#############################################"

## INSTALA PACOTES

echo
echo "## Installing Packages ..."
echo
sleep 1

if [ $DIST = "REDHAT" ]
then
	echo "# Installing tmux ... "
	dnf install tmux -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing wget ..."
	dnf install wget -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing ssh ..."
	dnf install ssh -y > /dev/null || echo "Error, please do it manually!"

	if ps -e | grep -Eiq "\bgnome-"
	then
		echo "# Installing gnome-tweaks ..."
		dnf install gnome-tweaks -y > /dev/null || echo "Error, please do it manually!"
	fi

	echo "# Installing vim ..."
	dnf install vim -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing htop ..."
	dnf install htop -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing  alien ..."
	dnf install alien -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing pv ..."
	dnf install pv -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing wmctrl ..."
	dnf install wmctrl -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing acpi ..."
	dnf install acpi -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing firefox-x11 .."
	dnf install firefox-x11 -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing flash-plugin ..."
	dnf install flash-plugin -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing flash-player ..."
	dnf install flash-player -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing mellowplayer ..."
	dnf install mellowplayer -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing spotify ..."
	dnf install lpf-spotify-client -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing bash-completion ..."
	dnf install bash-completion -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing homebank ..."
	dnf install homebank -y > /dev/null || echo "Error, please do it manually!"
	
	echo "## Installing DropBox"
	sleep 1

	if [ $ARCH = "64" ]
	then
		echo "# Downloading dropbox 64 bits (RPM) ..."
		wget -O $dropbox_64_fedora_rpm $dropbox_64_fedora || echo "Error, please do it manually!"

		echo "# Installing $dropbox_64_fedora_rpm..."
		rpm -i $dropbox_64_fedora_rpm > /dev/null || echo "Error, please do it manually!"

		echo "# Removing cache ..."
		rm -f $dropbox_64_fedora_rpm || echo "Error, please do it manually!"
	else
		echo "# Downloading dropbox 32 bits (RPM)"
		wget -O $dropbox_32_fedora_rpm $dropbox_32_fedora || echo "Error, please do it manually!"

		echo "# Installing $dropbox_32_fedora_rpm ..."
		rpm -i $dropbox_32_fedora_rpm || echo "Error, please do it manually!"

		echo "# Removing cache ..."
		rm -f $dropbox_32_fedora_rpm || echo "Error, please do it manually!"
	fi
	echo
	echo "Done!"
	else
		echo "# Installing tmux ..."
		apt install tmux -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing wget ..."
		apt install wget -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing ssh ..."
		apt install ssh -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing vim ..."
		apt install vim -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing htop ..."
		apt install htop -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing alien ..."
		apt install alien -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing pv ..."
		apt install pv -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing wmctrl ..."
		apt install wmctrl -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing acpi ..."
		apt install acpi -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing flash-plugin ..."
		apt install flash-plugin -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing flash-player ..."
		apt install flash-player -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing bash-completion ..."
		apt install bash-completion -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing homebank ..."
		apt install homebank -y > /dev/null || echo "Error, please do it manually!"
		echo "## Installing DropBox"
		sleep 1

	if [ $ARCH = "64" ]
	then
		echo "# Downloading dropbox 64 bits (DEB) ..."
		wget -O $dropbox_64_debian_deb $dropbox_64_debian || echo "Error, please do it manually!"

		echo "# Installing $dropbox_64_debian_deb ..."
		dpkg -i $dropbox_64_debian_deb > /dev/null || echo "Error, please do it manually!"

		echo "# Removing cache ..."
		rm -f $dropbox_64_debian_deb || echo "Error, please do it manually!"
	else
		echo "# Downloading dropbox 32 bits (DEB)"
		wget -O $dropbox_32_debian_deb $dropbox_32_debian || echo "Error, please do it manually!"

		echo "# Installing $dropbox_32_debian_deb ..."
		dpkg -i $dropbox_32_debian_deb || echo "Error, please do it manually!"

		echo "# Removing cache ..."
		rm -f $dropbox_32_debian_deb || echo "Error, please do it manually!"
	fi

	echo
	echo "Done!"
fi

	echo
	echo "#############################################"

## CONFIGURAR XORG COMO DEFAULT

	if [ -f /etc/fedora-release ]
	then

		echo
		echo "## Configuring Xorg as default ..."
		sleep 1
		sed -i "/daemon/a\DefaultSession=gnome-xorg.desktop" /etc/gdm/custom.conf || echo "Error, please do it manually!"

		echo
		echo "## Disabling Wayland ..."
		sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf || echo "Error, please do it manually!"
	
		echo
		sleep 1
		echo "Done!"
		echo
		echo "#############################################"
		echo

	fi

## AVISOS

	echo "## ATTENTION !!!"
	echo
	echo " -> Don't forget, install the Gnome Extensions manually: https://extensions.gnome.org/"
	echo


## OPÇÃO REBOOT

while true
do

	read -p "Would you like to restart the System? (y/n)" RESPOSTA_REBOOT
	echo

	case $RESPOSTA_REBOOT in

		y|Y)
			echo "Rebooting ."
			sleep 1
			echo "Rebooting .."
			sleep 1
			echo "Rebooting ..."
			sleep 1
			reboot now
			;;

		n/N)
			echo "Finished Script!"
			break
			;;

		*)
			echo "Invalid Option!"
			continue
	
	esac
done


