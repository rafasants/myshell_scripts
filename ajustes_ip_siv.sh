#!/bin/bash

DNS_SIV="10.60.17.10"
NTP_SIV="10.60.17.10"
GW_SIV="10.60.48.1"
ZABBIX_SIV="10.60.17.69"
IP_DISTRIBUIDOR1="10.60.17.30"
IP_DISTRIBUIDOR2="10.60.17.31"
IP_TEMPO_RAIOX="10.60.17.5"
TEMPO_RAX="30"
TEMPO_SIV="90"

function principal() {
CONFIG=$(zenity --forms --title="CONFIGURAÇÃO SIV - SBCT/CTTI" --text="Preencha os campos com a informação do SIV:" \
	--separator="," \
	--add-entry="Nome Máquina (Formato CT-XXXXXXX ou CTXXXXXXX) :" \
	--add-entry="IP Máquina (Formato 10.60.X.X) :" \
	--add-combo="IP Distribuidor:" \
	--combo-values=\|10.60.17.30\|10.60.17.31 \
	--add-combo="Instalar Tempo Raio-X?" \
	--combo-values=SIM\|NÃO \
	--add-combo="Instalar Driver Elcoma? *(Somente Mini CPU Elcoma)" \
	--combo-values=SIM\|NÃO \
	--add-combo="SIV VIDEOWALL? *(Somente Mini CPU IndoorMidia)" \
	--combo-values=SIM\|NÃO)
	if [ $? -eq 0 ]
	then
		NOME_MAQUINA=$(echo $CONFIG | cut -d, -f1)
		IP_SIV=$(echo $CONFIG | cut -d, -f2)
		IP_DISTRIBUIDOR=$(echo $CONFIG | cut -d, -f3)
		TEMPO_RAIOX=$(echo $CONFIG | cut -d, -f4)
		ELCOMA=$(echo $CONFIG | cut -d, -f5)
		VIDEOWALL=$(echo $CONFIG | cut -d, -f6)
		confere $NOME_MAQUINA $IP_SIV $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	else
		exit 0
	fi
}


function confere(){
	zenity --height=100 --width=250 --question --title="Configuração SIV - SBCT/CTTI" --text="

	
	º Nome Máquina: `test "$NOME_MAQUINA" == "" && cat /etc/hostname || echo $NOME_MAQUINA`
	º IP Distribuidor: `test "$IP_DISTRIBUIDOR" == "10.60.17.30" -o "$IP_DISTRIBUIDOR" == "10.60.17.31" && echo $IP_DISTRIBUIDOR || cat /home/siso_monitor/Visualizador/iniciar.sh | grep HOST= | cut -d'=' -f2 | tr -d "'"`
	º IP SIV: `test "$IP_SIV" == "" && sudo hostname -i | awk '{print$2}' || echo $IP_SIV`
        ××××××××××××××××××××××××××××××××××××××××××××××××

	º GATEWAY: `sudo cat /etc/NetworkManager/system-connections/eth0 | grep address1 | cut -d "=" -f 2 | cut -d "/" -f 2 | cut -d "," -f 2`
	º ZABBIX: `cat /etc/zabbix/zabbix_agentd.conf | grep Server= | grep -v '#' | cut -d '=' -f 2`
	º NTP: `cat /etc/ntp.conf | grep server | grep -v '#' | cut -d ' ' -f 2`
	××××××××××××××××××××××××××××××××××××××××××××××××
	º INSTALAR TEMPO RAIO-X? `test "$TEMPO_RAIOX" == "SIM" && echo "  [SIM]  NÃO  " || echo "  SIM  [NÃO]  "`
	××××××××××××××××××××××××××××××××××××××××××××××××
	º INSTALAR DRIVER ELCOMA? `test "$ELCOMA" == "SIM" && echo "  [SIM]  NÃO  " || echo "  SIM  [NÃO]  "`
		* ATENÇÃO: Somente para Mini CPU's ELCOMA
	××××××××××××××××××××××××××××××××××××××××××××××××
	º SIV VIDEOWALL? `test "$VIDEOWALL" == "SIM" && echo "  [SIM]  NÃO  " || echo "  SIM  [NÃO]  "`
	××××××××××××××××××××××××××××××××××××××××××××××××

	As Informações estão corretas?"

	if [ $? -eq 0 ]
	then
		alterar_nome $NOME_MAQUINA $IP_SIV $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	else
		principal
	fi
}

alterar_nome () {  
	if [ "$NOME_MAQUINA" != "" ]
	then
	(
        	echo "40" ; sleep 1
        	echo "# Alterando Nome para $NOME_MAQUINA"; sleep 1
		sudo sed -i "s/.*/$NOME_MAQUINA/" /etc/hostname
		echo "99" ; sleep 1
		echo "# Alterando Hostname Zabbix" ; sleep 1
		sudo sed -i "s/Hostname=.*/Hostname=$NOME_MAQUINA/" /etc/zabbix/zabbix_agentd.conf
	) |

		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Alterando Hostname..." \
		--auto-close \
		--percentage=0
		--height=100
		alterar_ip $IP_SIV $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	else
		alterar_ip $IP_SIV $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	fi
}

alterar_ip () {
    
	if [ "$IP_SIV" != "" ]
	then
	(
        	echo "20" ; sleep 1
        	echo "# Removendo conexões existentes ..." ; sleep 1
		sudo rm -f /etc/NetworkManager/system-connections/*
        	echo "30" ; sleep 1
        	echo "# Alterando Endereços eth0 ..." ; sleep 1
		sudo nmcli connection add type ethernet con-name eth0 ifname eth0 ip4 $IP_SIV/20 gw4 $GW_SIV
		sudo nmcli connection modify eth0 ipv4.dns $DNS_SIV
		sudo nmcli connection modify eth0 ipv4.dns-search "infraero.gov.br"
		sudo nmcli connection modify eth0 ipv6.method ignore
		sudo nmcli connection modify eth0 connection.autoconnect yes
        	echo "70" ; sleep 1
        	echo "# Alterando Servidor NTP para $NTP_SIV" ; sleep 1
		sudo sed -i "s/server.*/server $NTP_SIV/" /etc/ntp.conf
		echo "99" ; sleep 1
        	echo "# Alterando IP Servidor Zabbix para $ZABBIX_SIV" ; sleep 1
		sudo sed -i "s/Server=.*/Server=$ZABBIX_SIV/" /etc/zabbix/zabbix_agentd.conf
		sudo sed -i "s/ServerActive=.*/ServerActive=$ZABBIX_SIV/" /etc/zabbix/zabbix_agentd.conf
	) |
		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Alterando Interface eth0..." \
		--auto-close \
		--percentage=0
		--height=100
		alterar_distribuidor $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	else
		alterar_distribuidor $IP_DISTRIBUIDOR $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	fi
}

alterar_distribuidor () {
	if [ "$IP_DISTRIBUIDOR" == "10.60.17.30" -o "$IP_DISTRIBUIDOR" == "10.60.17.31" ]
	then
	(
        	echo "99" ; sleep 1
        	echo "# Alterando IP Distribuidor para: $IP_DISTRIBUIDOR" ; sleep 1
		sed -i "s/HOST=.*/HOST=\'$IP_DISTRIBUIDOR\'/" /home/siso_monitor/Visualizador/iniciar.sh
	) |
		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Configurando Distribuidor..." \
		--auto-close \
		--percentage=0
		--height=100
		tmp_rx $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	else
		tmp_rx $TEMPO_RAIOX $ELCOMA $VIDEOWALL
	fi
}

tmp_rx () {
	if [ "$TEMPO_RAIOX" == "SIM" ]
	then
	(
		echo "70" ; sleep 1
        	echo "# Instalando Tempo Raio X ..." ; sleep 1
		# Permissão de execução aos arquivos
		sudo chmod a+x /home/siso_monitor/Tempo_raiox/tempo_raiox.sh
		sudo chmod a+x /home/siso_monitor/Tempo_raiox/inst/Tempo_Raiox.desktop
		# Configurando IP Tempo Raio X
		echo "70" ; sleep 1
        	echo "# Configurando Servidor Tempo Raio X para $IP_TEMPO_RAIOX ." ; sleep 1
		sudo sed -i "s/servidor=.*/servidor='$IP_TEMPO_RAIOX'/" /home/siso_monitor/Tempo_raiox/tempo_raiox.sh
		echo "75" ; sleep 1
        	echo "# Configurando Tela Raio X para $TEMPO_RAX segundos." ; sleep 1
		sudo sed -i "s/tempo_rax=.*/tempo_rax=$TEMPO_RAX/" /home/siso_monitor/Tempo_raiox/tempo_raiox.sh
		echo "75" ; sleep 1
        	echo "# Configurando Exibidor SIV para $TEMPO_SIV segundos." ; sleep 1		
		sudo sed -i "s/tempo_siv=.*/tempo_siv=$TEMPO_SIV/" /home/siso_monitor/Tempo_raiox/tempo_raiox.sh
		# instalar os aplicativos wmctrl, libxdo2 e xdotool e a Fonte da letra
		echo "80" ; sleep 1
        	echo "# Configurando wmctrl.deb ..." ; sleep 1
		sudo dpkg -i /home/siso_monitor/Tempo_raiox/inst/wmctrl.deb
		echo "80" ; sleep 1
        	echo "# Configurando libxdo3.deb ..." ; sleep 1
		sudo dpkg -i /home/siso_monitor/Tempo_raiox/inst/libxdo3.deb
		echo "80" ; sleep 1
        	echo "# Configurando xdotool.deb ..." ; sleep 1
		sudo dpkg -i /home/siso_monitor/Tempo_raiox/inst/xdotool.deb
		echo "85" ; sleep 1
        	echo "# Configurando Fonte ..." ; sleep 1
		sudo mkdir -p /usr/share/fonts/truetype/raiox
		sudo cp /home/siso_monitor/Tempo_raiox/inst/HUMANIST_777_BT_Black.TTF /usr/share/fonts/truetype/raiox
		sudo fc-cache -f -v
		echo "85" ; sleep 1
        	echo "# Configurando Tempo Raio X na inicialização do sistema ..." ; sleep 1
		sudo cp /home/siso_monitor/Tempo_raiox/inst/Tempo_Raiox.desktop /home/siso_monitor/.config/autostart/	
		# criar 2 Espaços de Trabalho
		echo "95" ; sleep 1
        	echo "# Configurando Tempo Raio X, Aguarde ..." ; sleep 1
		wmctrl -n 2
		firefox -ProfileManager /home/siso_monitor/Tempo_raiox/inst/r_kiosk-0.9.0-fx.xpi &
		/bin/sleep 3
		xdotool key "alt+o"
		/bin/sleep 1
		xdotool key "KP_Enter"
		/bin/sleep 10
		verif=$(pgrep -f "/usr/lib/firefox/firefox*")
		while [ -z $verif ]; do
		verif=$(pgrep -f "/usr/lib/firefox/firefox*")
		done
		/bin/sleep 10
		xdotool key "alt+i"
		/bin/sleep 5
		pkill firefox
	) |
		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Configurando Tempo Raio-X..." \
		--auto-close \
		--percentage=0
		--height=100
		driver_elcoma $ELCOMA $VIDEOWALL
	else
		driver_elcoma $ELCOMA $VIDEOWALL
	fi
}

function driver_elcoma() {
	if [ "$ELCOMA" == "SIM" ]
	then
	(
		echo "50" ; sleep 1
        	echo "# Instalando Driver Elcoma ..." ; sleep 1
		sudo cp /home/siso_monitor/Documentos/Driver\ Elcoma/sis671_drv.* /usr/lib/xorg/modules/drivers
		echo "98" ; sleep 1
        	echo "# Copiando Arquivos ELcoma ..." ; sleep 1
		sudo cp /home/siso_monitor/Documentos/Driver\ Elcoma/xorg.conf /etc/X11
	) |
		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Instalando Driver Elcoma..." \
		--auto-close \
		--percentage=0
		--height=100
		videowall_funcao  $VIDEOWALL
	else
		videowall_funcao  $VIDEOWALL
	fi
}

function videowall_funcao() {
	if [ "$VIDEOWALL" == "SIM" ]
	then
	(
		echo "70" ; sleep 1
        	echo "# Configurando resolução." ; sleep 1
		sudo sed -i "s/#GRUB_GFXMODE=640x480/GRUB_GFXMODE=800x600/g" /etc/default/grub
		echo "100" ; sleep 1
        	echo "# Updating-grub ..." ; sleep 1
		sudo update-grub
	) |
		zenity --progress \
		--title="Configurando, Aguarde..." \
		--text="Configurando SIV VideoWall..." \
		--auto-close \
		--percentage=0
		--height=100
		reiniciar
	else
		reiniciar
	fi
}

function reiniciar() {
		zenity --question --title="SIV Configurado!" --text="Deseja Reiniciar?"
		if [ $? -eq 0 ]
			then
				sudo reboot now
			else
				exit 0
		fi
}

sudo killall java VisualizadorJava.jar
sudo killall monitora_siv.sh
sudo killall tempo_raiox.sh
sudo killall firefox
principal
