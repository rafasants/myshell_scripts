#!/bin/bash

exec 1 >> >(tee -a ~/configura.log)
exec 2>&1 >(tee -a ~/configura.log)

SENHA_ROOT='xxxxxxxxxxxxxxxxxxxxxxxxxxxx'

#############################################################################################
####################              AUTHOR: RAFAEL SANTOS                  ####################
########	      This script makes my basics Linux configurations.              ########
#####             Like: Install some Packages, update system based on DIST              #####
###                    	  	  and edit some Config Files.                             ###
## 											   ##
###					./configura.sh					  ###
####                                			                                #####
########		        	     v1.6				     ########
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

	echo "# Adding $USUARIO to sudo group ..."
	sleep 1
	usermod -G sudo $USUARIO || echo "Error, please do it manually!"
	
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
	echo "# Repositories are updated!"
	apt upgrade -y > /dev/null || echo "Error, please do it manually!"
	echo "# All packages are updated!"
	apt clean > /dev/null || echo "Error, please do it manually!"
	apt autoclean > /dev/null || echo "Error, please do it manually!"

	echo
	echo "$DIST Updated!"
	sleep 1
	echo "Done!"
else
	echo "## Installing RPM Fusion Repository for FEDORA..."
	echo

	dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y > /dev/null || echo "Error, please do it manually!"

	echo "# System Upgrading... (Maybe this whill take around 10 minutes... DO NOT PRESS ANY KEY )"
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

## INSTALA NUMLOCKX E CONFIGURA (if DIST=gdm)

if ps axu | grep -q "^gdm"
then
	if [ $DIST = "REDHAT" ]
	then
		echo
		echo "## Installing Numlockx ..."
		echo

		dnf install numlockx -y > /dev/null || echo "Error, please do it manually!"

		echo "# Configuring numlockx.desktop ..."
		sleep 1

		touch /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"
		echo -e "[Desktop Entry]\n\nVersion=0\nType=Application\nName=Numlockx\nDescription=Enable Numlock at boot\nExec=/usr/bin/numlockx on" > /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"

		echo "Done!"
		echo
		echo "#############################################"

	elif [ $DIST = "DEBIAN" ]
		then
			echo
			echo "## Installing Numlockx ..."
                echo

                apt install numlockx -y > /dev/null || echo "Error, please do it manually!"

                echo "# Configuring numlockx.desktop ..."
                sleep 1

                touch /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"
                echo -e "[Desktop Entry]\n\nVersion=0\nType=Application\nName=Numlockx\nDescription=Enable Numlock at boot\nExec=/usr/bin/numlockx on" > /usr/share/gdm/greeter/autostart/numlockx.desktop || echo "Error, please do it manually!"

                echo "Done!"
                echo
                echo "#############################################"
	fi
else
	echo "GDM as Display Manager was not Detected!"
fi

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

	if grep -q "net.ifnames=0"  /etc/default/grub
	then
		echo "eth0 has already been configured!"
	else
		echo "# Setting Network Interface Name to eth0 ..."
		sleep 1
		sed -ri "s/(.*CMDLINE.*)\"(.*)\"/\1\"\2 net.ifnames=0\"/" /etc/default/grub || echo "Error, please do it manually!"
	fi

######## FIX THE KEYBOARD BUG WHEN THE O.S WAS SUSPENDED


	echo
	if dmesg | grep -q "i8042"
	then
		echo "Fixing the keyboard bug when the OS is suspend ..."
        	sed -ri "s/(.*CMDLINE.*)\"(.*)\"/\1\"\2 i8042.direct i8042.dumbkbd\"/" /etc/default/grub || echo "Error, please do it manually!"
	fi

####### UPDATE THE GRUB FILE

	echo "# Updating GRUB ..."
	echo

	grub2-mkconfig -o /boot/grub2/grub.cfg 2> /dev/null || grub-mkconfig -o /boot/grub/grub.cfg

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
	yum install tmux -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing wget ..."
	yum install wget -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing ssh ..."
	yum install ssh -y > /dev/null || echo "Error, please do it manually!"

	if ps -e | grep -Eiq "\bgnome-"
	then
		echo "# Installing gnome-tweaks ..."
		yum install gnome-tweaks -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing chrome-gnome-shell ..."
		yum install chrome-gnome-shell -y > /dev/null || echo "Error, please do it manually!"
	fi

	echo "# Installing vim ..."
	yum install vim -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing  alien ..."
	yum install alien -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing pv ..."
	yum install pv -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing wmctrl ..."
	yum install wmctrl -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing acpi ..."
	yum install acpi -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing mellowplayer ..."
	yum install mellowplayer -y > /dev/null || echo "Error, please do it manually!"
	
	echo "Wait!"
	(cd /usr/share/pixmaps && wget https://s3.amazonaws.com/allaboutjazz/photos/news/deezer250.png -O deezer.png)
	sed -i "s/^Name=MellowPlayer/Name=Deezer/g" /usr/share/applications/mellowplayer.desktop
	sed -i "s/^StartupNotify=.*/StartupNotify=false/g" /usr/share/applications/mellowplayer.desktop
	sed -i "s/^Icon=mellowplayer/Icon=\/usr\/share\/pixmaps\/deezer.png/g" /usr/share/applications/mellowplayer.desktop
	
	echo "# Installing Conky ..."
	yum install conky -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing Gimp ..."
	yum install gimp -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing exfat-utils"
	yum install exfat-utils -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installling fuse-exfat ..."
	yum install fuse-exfat -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing spotify ..."
	yum install lpf-spotify-client -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing bash-completion ..."
	yum install bash-completion -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing homebank ..."
	yum install homebank -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing samba ..."
	yum install samba -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing Xpad..."
	yum install xpad -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing wine ..."
	yum install wine -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing qbittorrent"
	yum install qbittorrent -y > /dev/null || echo "Error, please do it manually!"	
	echo "# Installing conky-manager ..."
	yum install conky-manager -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing DropBox ..."
	yum install nautilus-dropbox -y > /dev/null || echo "Error, please do it manually!"
	echo "# Installing vagrant ..."
	yum install vagrant -y > /dev/null || echo "Error, please do it manually!"	

	echo "## Installing Virtualbox 6.0.16 ..."
	yum install https://download.virtualbox.org/virtualbox/6.0.16/VirtualBox-6.0-6.0.16_135674_fedora31-1.x86_64.rpm -y > /dev/null || echo "Error, please do it manually!"
	echo "# Downloading VirtualBox Extension Pack ..."
	wget https://download.virtualbox.org/virtualbox/6.0.16/Oracle_VM_VirtualBox_Extension_Pack-6.0.16.vbox-extpack -O /tmp/Oracle_VM_VirtualBox_Extension_Pack-6.0.16.vbox-extpack
	echo
	echo "# Configuring VirtualBox Extension Pack ..."
	VBoxManage extpack install /tmp/Oracle_VM_VirtualBox_Extension_Pack-6.0.16.vbox-extpack || echo "Error, please do it manually!"
	
	echo
	echo "# Adding the user $USUARIO to vboxusers group"
	usermod -aG vboxusers $USUARIO
	echo "VBox Done!"

	echo "# Installing kernel-devel ..."
	yum install kernel-devel -y > /dev/null || echo "Error, please do it manually!"
	echo
	echo "Done!"
	else
		echo "# Installing tmux ..."
		apt install tmux -y > /dev/null || echo "Error, please do it manually!"

		if ps -e | grep -Eiq "\bgnome-"
        	then
			echo "# Installing gnome-tweaks ..."
			apt install gnome-tweaks -y > /dev/null || echo "Error, please do it manually!"
			echo "# Installing chrome-gnome-shell ..."
			apt install chrome-gnome-shell -y > /dev/null || echo "Error, please do it manually!"
		fi

		echo "# Installing Conky ..."
		apt install conky -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing conky-manager ..."
		apt install conky-manager -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing wget ..."
		apt install wget -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing ssh ..."
		apt install ssh -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing samba ..."
		apt install samba -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing vim ..."
		apt install vim -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing exfat-utils ..."
		apt install exfat-utils -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing exfat-fuse ..."
		apt install exfat-fuse -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing alien ..."
		apt install alien -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing pv ..."
		apt install pv -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing Gimp ..."
		apt install gimp -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing Xpad..."
		apt install xpad -y > /dev/null || echo "Error, please do it manually!"
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
		echo "# Installing DropBox"
		apt install nautilus-dropbox -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing bitorrent"
		apt install bittorrent-gui -y > /dev/null || echo "Error, please do it manually!"
		echo "# Installing kernel-devel ..."
		apt install kernel-devel -y > /dev/null || echo "Error, please do it manually!"
		echo "Done!"
fi

	echo
	echo "#############################################"

##[[DISABLED]] CONFIGURAR XORG COMO DEFAULT NO FEDORA

#	if [ -f /etc/fedora-release ]
#	then
#
#		echo
#		echo "## Configuring Xorg as default ..."
#		sleep 1
#		sed -i "/daemon/a\DefaultSession=gnome-xorg.desktop" /etc/gdm/custom.conf || echo "Error, please do it manually!"
#
#		echo
#		echo "## Disabling Wayland ..."
#		sed -i "s/#WaylandEnable=false/WaylandEnable=false/" /etc/gdm/custom.conf || echo "Error, please do it manually!"
#	
#		echo
#		sleep 1
#		echo "Done!"
#		echo
#		echo "#############################################"
#		echo
#
#	fi

## Setting keyboard layout

echo "## Setting keyboard layout ..."

sudo setxkbmap -model abnt2 -layout br || echo "Error, please do it manually!"
sleep 2

## Download and install Freshplayer lib

echo "## Downloading FreshPlayer from Github ..."
wget https://github.com/i-rinat/freshplayerplugin/archive/master.zip -O /tmp/master.zip  || echo "Error, please do it manually!"
echo "Unziping FreshPlayer ..."
(cd /tmp && unzip master.zip)  || echo "Error, please do it manually!"

echo "Installing dependences ..."
(cd /tmp/freshplayerplugin-master && mkdir build) || echo "Error, please do it manually!"


if [ $DIST="REDHAT" ]
then
		sudo dnf install cmake gcc gcc-c++ pkgconfig ragel alsa-lib-devel openssl-devel \
             glib2-devel pango-devel mesa-libGL-devel libevent-devel gtk2-devel         \
             libXrandr-devel libXrender-devel libXcursor-devel libv4l-devel             \
             mesa-libGLES-devel  ffmpeg-devel libva-devel libvdpau-devel libdrm-devel   \
             pulseaudio-libs-devel libicu-devel -y
else
        sudo apt-get install cmake gcc g++ pkg-config ragel libasound2-dev \
            libssl-dev libglib2.0-dev libpango1.0-dev libgl1-mesa-dev     \
            libevent-dev libgtk2.0-dev libxrandr-dev libxrender-dev       \
            libxcursor-dev libv4l-dev libgles2-mesa-dev libavcodec-dev    \
            libva-dev libvdpau-dev libdrm-dev libicu-dev -y
fi

echo "Preparing to compile ..."
(cd /tmp/freshplayerplugin-master/build && cmake ..)  || echo "Error, please do it manually!"
 
echo "Compiling ..."
(cd /tmp/freshplayerplugin-master/build && make) || echo "Error, please do it manually!"

echo "Copying libfreshwrapper-flashplayer.so to mozilla plugins folder ..."
cp /tmp/freshplayerplugin-master/build/libfreshwrapper* ~$USUARIO/.mozilla/plugins/  || echo "Error, please do it manually!"

echo

## ALTERA HOSTNAME

	echo "#############################################"
	echo "## Setting hostname to: hostname ..."
	sed -i "s/.*/localhost/g" /etc/hostname
	echo
	echo "#############################################"
	echo

### CRIANDO E HABILITANDO RC.LOCAL CASO NÃO EXISTA

if [ ! -e /etc/rc.local ]
then

echo "## Configuring rc.local ..."

touch /etc/systemd/system/rc-local.service || echo "Error, please do it manually!"

echo "[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/rc-local.service

touch /etc/rc.local || echo "Error, please do it manually!"

echo -n "#!/bin/sh -e
        
exit 0" > /etc/rc.local

chmod +x /etc/rc.local || echo "Error, please do it manually!"

echo "# Enabling rc.local on boot ..."
systemctl enable rc-local || echo "Error, please do it manually!"

echo "Done!"
else
        echo "rc.local has already configured!"
fi

echo
echo "#############################################"
echo


## CONFIGURA CONKY (GOTHAM)

CONKY_FILE_AUTOSTART=~$USUARIO/.config/autostart/conky.desktop
CONKY_SCRIPT=/home/$USUARIO/.conky/conky-startup.sh
CONKY_GOTHAM=/home/$USUARIO/.conky/Gotham/Gotham

echo "# Creating conky.desktop at ~/.config/autostart/ ..."

touch $CONKY_FILE_AUTOSTART || echo "Error, please do it manually!"
chmod 544 $CONKY_FILE_AUTOSTART || echo "Error, please do it manually!"

echo "[Desktop Entry]
Type=Application
Exec=sh "/home/$USUARIO/.conky/conky-startup.sh"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_IN]=Conky
Name=Conky" > $CONKY_FILE_AUTOSTART || echo "Error, please do it manually!"

echo "# Creating script conky at ~/.conky/ ..."

touch $CONKY_SCRIPT || echo "Error, please do it manually!"
chmod 544 $CONKY_SCRIPT || echo "Error, please do it manually!"

echo "sleep 20s
killall conky
cd "/home/$USUARIO/.conky/Gotham"
conky -c "/home/$USUARIO/.conky/Gotham/Gotham" &" > $CONKY_SCRIPT || echo "Error, please do it manually!"

echo "Creating Gotham config file ..."

touch $CONKY_GOTHAM || echo "Error, please do it manually!"
chmod 544 $CONKY_GOTHAM || echo "Error, please do it manually!"

echo "use_xft yes
xftfont 123:size=8
xftalpha 0.1
update_interval 1
total_run_times 0

own_window yes
own_window_type normal
own_window_transparent yes
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
own_window_colour 000000
own_window_argb_visual yes
own_window_argb_value 0

double_buffer yes
#minimum_size 250 5
#maximum_width 500
draw_shades yes
draw_outline no
draw_borders no
draw_graph_borders no
default_color white
default_shade_color black
default_outline_color green
alignment top_right
gap_x 0
gap_y 135
no_buffers yes
uppercase no
cpu_avg_samples 2
net_avg_samples 1
override_utf8_locale yes
use_spacer right


minimum_size 0 0
TEXT
${voffset 10}${color EAEAEA}${font GE Inspira:pixelsize=120}${time %H:%M}${font}${voffset -84}${offset 10}${color FFA300}${font GE Inspira:pixelsize=42}${time %d} ${voffset -15}${color EAEAEA}${font GE Inspira:pixelsize=22}${time  %B} ${time %Y}${font}${voffset 24}${font GE Inspira:pixelsize=58}${offset -148}${time %A}${font}
${voffset 1}${offset 12}${font Ubuntu:pixelsize=12}${color FFA300}HD ${offset 9}$color${fs_free /} / ${fs_size /}${offset 30}${color FFA300}RAM ${offset 9}$color$mem / $memmax${offset 30}${color FFA300}CPU ${offset 9}$color${cpu cpu0}%" > $CONKY_GOTHAM || echo "Error, please do it manually!"

echo "Done!"
echo

echo "#############################################"
echo

## CRIA SCRIPT PARA LIMPAR CACHE PESSOAL E ADICIONA NO ANACRONTAB DAILY 

echo "# Creating the scripts folder on /home ..."
mkdir -p /home/$USUARIO/scripts || echo "Error, please do it manually!"

echo "# Creating the script cache_clean ..."
touch /home/$USUARIO/scripts/cache_clean.sh || echo "Error, please do it manually!"
chmod +x /home/$USUARIO/scripts/cache_clean.sh || echo "Error, please do it manually!"

echo "
#!/bin/bash

CACHE_SIZE=$(eval du -s ~$USUARIO/.cache | cut -f1)


	if [ $CACHE_SIZE -gt "1000000" ]
	then
		sudo rm -rf /home/$USUARIO/.cache
	fi" > /home/$USUARIO/scripts/cache_clean.sh || echo "Error, please do it manually!"

echo "# Configuring anacron ..."

        sudo chmod 666 /etc/anacrontab

        echo "@weekly   6       clean.weekly    /home/$USUARIO/scripts/cache_clean.sh" >> /etc/anacrontab || echo "Error, please do it manually!"

        sudo chmod 644 /etc/anacrontab

echo "# Done!"
echo
echo "#############################################"
echo

## AVISOS

	if ps -e | grep -Eiq "\bgnome-"
        then
		echo "## ATTENTION !!!"
		echo
		echo " -> Don't forget, install the Gnome Extensions manually: https://extensions.gnome.org/"
		echo
	fi
	

	echo "Finally Done!!"
	sleep 5

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
			echo "End of Script!"
			break
			;;

		*)
			echo "Invalid Option!"
			continue
	
	esac
done
