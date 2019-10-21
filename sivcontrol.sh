#!/bin/bash

##############################
#
# EXECUTAR COMANDO EM UMA LISTA DE SIVS
#
#
### R E A D  M E : ###
#
#  1. NECESSARIO CRIAR A LISTA DE IP'S (POR LINHA) NO /home/sbct/ e deixar última linha em branco
#
#  2. NECESSARIO INSTALAR O PACOTE SSHPASS
#
#
stty intr ""
#sudo sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config


resposta="N"
password="ctt1"
log=(ls log -cl | awk '{print$5}')
lista_log="/home/sbct/listas/log"

#### MENU PRINCIPAL ####

Principal() {
	clear
	echo ""
	echo "-------------------------------"
	echo "| Autor: RAFAEL SANTOS - CTTI |"
	echo "-------------------------------"
	echo -e "\e[31m     _ _                                _
    | (_)_ __  _   ___  __          ___(_)_   __
    | | | '_ \| | | \ \/ /  _____  / __| \ \ / /
    | | | | | | |_| |>  <  |_____| \__ \ |\ V /
    |_|_|_| |_|\__,_/_/\_\         |___/_| \_/\e[0m"
	echo ""
	echo  "##############################################"
	echo  "###  EXECUTAR COMANDO EM UM GRUPO DE SIVS  ###"
	echo  "##############################################"
	echo ""
	echo "-----------------------------------------------"
	echo ""
	sleep 0.5
	echo "1. Selecione o grupo de SIVS:"
	echo ""
	echo "-------------------------------------------------" 
	echo "|  [1]  Checkin's (Necessario senha)            |"
	echo "|  [2]  Concessionarios                         |"
	echo "|  [3]  Videowall's                             |"
	echo "|  [4]  SIVS Tempo Raio-X                       |"
	echo "|  [5]  Todos (Necessario senha)                |"
    	echo "|  [6]  SIV Individual                          |"
	echo "|  [7]  Lista Personalizada  (Necessario senha) |"
	echo "|  [8]  Totens Validação Credencial (Necessario |"
	echo "|  senha)					      |"
	echo "-------------------------------------------------"
	echo ""
	echo "[9] SAIR"
	echo "[10] VOLTAR PAG. INICIAL"
	echo ""
	read -p "Opcao: " opcao
	
case $opcao in
	1) Senha ;;
	2) Concessionarios ;;
	3) Videowall ;;
	4) Tempo_raiox ;;
	5) Senha ;;
	6) Individual ;;
	7) Senha ;;
	8) Senha ;;
	9) clear ; echo -e "\e[7mVoce foi desconectado.\e[27m" ; sleep 0.5 ; exit 0 ;;
	10) inicial.sh ;;
	*) echo -e "\e[7mOpcao desconhecida. \e[27m" ; sleep 0.5 ; clear ; Principal
esac
}

#### MENU 2 ####

Selecionar_comando() {
	clear
	echo "2. Selecione o comando:"
	echo ""
	echo "Grupo selecionado: $grupo"
	echo "---------------------------------------------"
	echo "|  [1]  Reiniciar                            |"
	echo "|  [2]  Reiniciar processo SIV Exibidor      |"
	echo "|  [3]  Matar processo Firefox               |"
	echo "|  [4]  Digitar comando                      |"
	echo "---------------------------------------------"
	echo ""
	echo -e "[5] VOLTAR"
	echo -e "[6] SAIR"
	echo ""
	read -p "Opcao: " opcao2
	
case $opcao2 in
	1) Reiniciar ;;
	2) Killall_siv ;;
	3) Killall_firefox ;;
	4) test $opcao == "1" -o $opcao = "5" -o $opcao = "7" -o $opcao = "8" && Outro_comando || Senha ;;
	5) clear ; echo -e "\e[7mVoltando ao menu anterior...\e[27m" ; sleep 0.5 ; clear ; Principal ;;
	6) clear ; echo -e "\e[7mVoce foi desconectado.\e[27m" ; sleep 0.5 ; exit 0 ;;
	*) echo -ne "\e[7mOpcao desconhecida. \e[27m" ; echo "" ; Selecionar_comando
esac
}

#### FUNÇÃO SENHA ####

Senha() {
clear
echo ""
echo -e "[5] VOLTAR"
echo ""
echo -ne "Digite a senha: "
read -s senha
senha=$(echo $senha|tr -d [:space:] )
if [ -z $senha ]
then
    echo -e "\e[7mDigite a senha!\e[27m"
    sleep 0.7
    Senha
fi
if [ $senha = "5" ] && [ $opcao2 -eq 4 ]
then
    clear
    echo -e "\e[7mVoltando ao menu anterior...\e[27m"
    sleep 0.5
    Selecionar_comando
fi
if [ $senha = "5" ]
then
    clear
    echo -e "\e[7mVoltando ao menu anterior...\e[27m"
    sleep 0.5
    Principal
elif [ $senha != $password ]
then
    clear
    echo "Senha incorreta, tente novamente!"
    sleep 0.7
    Senha
fi
if [ $opcao2 = "4" ] && [ $opcao != "0" ]
then
    Outro_comando
elif [ $opcao = "1" ]
then
    Checkins
elif [ $opcao = "5" ]
then
    Todos
elif [ $opcao = "7" ]
then
    Personalizado
elif [ $opcao = "8" ]
then
    Totens
fi
}

#### FUNCÃO: CONECTAR NAS MÁQUINAS SELECIONADAS POR SSH E EXECUTAR O COMANDO DESEJADO ####
Executar () {
echo "" > $lista_log
clear
declare -r STEPS=('step1' 'step2' 'step3' 'step4')
declare -r MAX_STEPS=${#STEPS[@]}
declare -r BAR_SIZE="##########"
declare -r MAX_BAR_SIZE=${#BAR_SIZE}
tput civis -- invisible
for step in "${!STEPS[@]}"; do
	perc=$(((step + 1) * 100 / MAX_STEPS))
	percBar=$((perc * MAX_BAR_SIZE / 100))
sleep 0.8
echo -ne "\\r[${BAR_SIZE:0:percBar}] $perc %"
echo -ne " Aguarde ..."
tput cnorm -- normal
done
sleep 0.5
clear
for ip in ` cat $lista`
do
echo ""
echo -e "\e[7m*** $ip ***\e[27m"
echo ""
sleep 1.5
sshpass -p "infraero" ssh -T siso_monitor@$ip << script
sudo $comando
exit 
script
if [ $? -ne 0 ]
then
	if [ $opcao2 -eq "1" ]
		then
			echo ""
        		echo " SIV  $ip Reiniciado!"
		else
        		echo ""
        		echo " -- ERRO: Não foi possível executar o comando: $comando no SIV  $ip"
        		echo "`date +%d/%m/%y-%H:%M` -- ERRO: Não foi possível executar o comando: $comando no SIV $ip" >> $lista_log
        		echo ""
	fi
else
echo "-- Comando: $comando executado com sucesso!"
echo "`date +%d/%m/%y-%H:%M` -- Comando: $comando executado com sucesso: $ip" >> $lista_log
echo ""
fi
echo "----------------------------------------------------------------"
done
echo ""
echo ""
cat $lista_log | grep ERRO
echo ""
echo ""
#sudo rm -f /home/sbct/listas/Individual
echo -n "Deseja executar outro comando? (S/N): "
read resposta2
resposta2=$(echo $resposta2|tr 'A-Z' 'a-z')
	if [ $resposta2 == "s" ]
	then
		unset comando
		unset resposta
		cd /home/sbct/scripts
		./script_linux_rafael.sh
	else
		echo -e "\e[7mVoce foi desconectado\e[27m"
		sleep 0.7
		exit 0
	fi
}

#### SELECIONA OS TOTENS DE VALIDAÇÃO DE CREDENCIAL ####
Totens() {
	lista="/home/sbct/listas/Totens"
	if [ -f $lista ]
	then
	    grupo=" -> Totens"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### SELECIONA OS SIVS DOS CHECKIN'S ####
Checkins() {
	lista="/home/sbct/listas/Checkins"
	if [ -f $lista ]
	then
	    grupo=" -> Checkins"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### SELECIONA OS SIVS DE TODOS OS CONCESSIONÁRIOS ####
Concessionarios() {
	lista="/home/sbct/listas/Concessionarios"
	if [ -f $lista ]
	then
	    grupo=" -> Concessionarios"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### SELECIONA OS SIVS DOS VIDEOWALLS ####
Videowall() {
	lista="/home/sbct/listas/Videowall"
	if [ -f $lista ]
	then
	    grupo=" -> Videowalls"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### SELECIONA TODOS OS SIVS QUE RODAM A PÁGINA DO TEMPO RAIO X #### 
Tempo_raiox() {
	lista="/home/sbct/listas/Tempo_raiox"
	if [ -f $lista ]
	then
	    grupo=" -> Tempo Raio-X"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### SELECIONA TODOS OS SIVS DO AEROPORTO ####
Todos() {
	lista="/home/sbct/listas/Todos"
	if [ -f $lista ]
	then
	    grupo=" -> TODOS OS SIVS"
	    Selecionar_comando
	else
	    sudo touch $lista && sudo chmod 777 $lista
	    clear
	    echo "Lista selecionada nao foi criada ou está vazia!"
	    sleep 1.2
	    clear
	    echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	    sleep 1.2
	    Principal
	fi
}

#### OPÇÃO PARA EXECUTAR COMANDO EM UM SIV INDIVIDUAL INFORMANDO SOMENTE O FINAL DO IP ####
Individual() {
	lista="/home/sbct/listas/Individual"
	clear
	echo ""
	echo -e "[5] VOLTAR"
	echo ""
	read -p "Digite o final do IP SIV: 10.60." ip_siv
	    if [ $ip_siv = "5" ]
	    then
	        clear
	        echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	        sleep 0.5
	        Principal
	        clear
	    fi
	    if [ -z $ip_siv ]
	    then
	        echo -e "\e[7mDigite o final do IP!\e[27m"
	        sleep 0.7
	        Individual
	    fi
        if [ $ip_siv == "50.160" ]
        then
            echo -e "\e[7mIP SERVIDOR!\e[27m"
            sleep 0.7
            Individual
        fi
	ip="10.60.$ip_siv"
	    if [ -e $lista ]
	    then
	        sudo echo -e "$ip\n" > $lista
            grupo=" -> INDIVIDUAL: $ip"
            Selecionar_comando
	    else
	        sudo touch $lista && chmod 777 $lista
	        echo -e "$ip\n" > $lista
            grupo=" -> INDIVIDUAL: $ip"
	        Selecionar_comando
	    fi
}

#### OPÇÃO PARA EXECUTAR UM COMANDO EM UMA LISTA PERSONALIZADA CRIADA NA HORA POR QUEM ESTA EXECUTANDO ESTE SCRIPT ####
Personalizado() {
	lista="/home/sbct/listas/Personalizado"
	grupo=" -> Personalizado"
	clear
	echo ""
	echo -e "[5] VOLTAR"
	echo ""
	echo "-- LISTA PERSONALIZADA: --"
	    if [ -e $lista ]
	    then
	        cat $lista
	        else
	        echo ""
	        echo "Nao existe nenhuma lista criada ainda!"
	        echo ""
	        sudo touch $lista
	        sudo chmod 777 $lista
	    fi
	echo "========================================="
	echo -ne "Deseja criar/subrescrever a lista personalizada? (S/N): "
	read reply
	reply=$(echo $reply|tr 'A-Z' 'a-z')
	    if [ $reply = "5" ]
	    then
	        clear
	        echo -ne "\e[7mVoltando ao menu anterior...\e[27m"
	        sleep 0.5
	        Principal
	        clear
	    fi
	    if [ $reply = "s" ]
	    then
	        clear
	        echo ""
	        echo "Digite os finais dos IP's sepadados por ESPACO. Exemplo: 49.70 50.131 ..."
	        read ip_personalizado
            echo $ip_personalizado | grep 50.160 >> /dev/null
        if [ $? -eq 0 ]
        then
            clear
            echo "Não digite 50.160, é o IP do servidor!"
            sleep 1.5
            clear
            Personalizado
        fi
    echo 10.60.$ip_personalizado > $lista
    echo "" >> $lista
    sed -i "s/\ /\n10.60./g" $lista
    sed -i "s/,/./g" $lista
    sed -i "s/;/./g" $lista
    clear
        if [ -z $lista ]
        then
            Personalizado
        fi
    echo "-- LISTA PERSONALIZADA --"
    cat $lista
    echo "A lista que voce digitou esta correta? (S/N)"
    read reply2
	    if [ $reply2 = "s" ]
	    then
	        Selecionar_comando
	    else
	        sudo rm -f $lista
    	    Personalizado
	    fi	
	    else
            Selecionar_comando
	fi
}
	
#### FUNÇÃO DE COMANDO PRÉ DETERMINADO PARA REINICIAR OS SIVS, DEPOIS DE SELECIONADOS ####
Reiniciar() {
	        while [ $resposta != "s" ]
	        do
	            comando="sudo reboot now"
	            alias_comando="Reiniciar"
	            clear	
	            echo ""
	            echo -e "\e[7m------------------- >>  A T E N C Ã O  !!! << ------------------- \e[27m "
	            echo ""
	            echo "Grupo selecionado:"
	            echo -e "   $grupo"
	            echo ""
	            echo ""	
	            echo -ne "Continuar com o comando: $alias_comando ? (S/N) "
	            read resposta
	            resposta=$(echo $resposta|tr 'A-Z' 'a-z')
	                if [ $resposta = "5" -o $resposta = "n" ]
	                then
	                    clear
	                    echo -e "\e[7mVoltando ao menu anterior...\e[27m"
	                    sleep 0.5
	                    Selecionar_comando
	                    clear
	                fi
	            clear
	        done
	Executar
}

#### FUNÇÃO DE COMANDO PRÉ DETERMINADO PARA REINICIAR EXIBIDOR DOS SIVS, DEPOIS DE SELECIONADOS ####
Killall_siv() {
	    while [ $resposta != "s" ]
	    do
	        comando="sudo killall java VisualizadorJava.jar ; sudo killall firefox ; sudo killall iniciar.sh ; sleep 3"
	        alias_comando="Matar processo SIV"
	        clear
	        echo ""
	        echo -e "\e[7m------------------- >>  A T E N C Ã O  !!! << ------------------- \e[27m "
	        echo ""
	        echo "Grupo selecionado:"
	        echo -e "   $grupo"
	        echo ""
	        echo ""
	        echo -ne "Continuar com o comando: $alias_comando ? (S/N) "
	        read resposta
	        resposta=$(echo $resposta|tr 'A-Z' 'a-z')
	            if [ $resposta = "5" -o $resposta = "n" ]
	            then
	                clear
	                echo -e "\e[7mVoltando ao menu anterior...\e[27m"
	                sleep 0.5
	                Selecionar_comando
	                clear
	            fi
	        clear
	    done
	Executar
}

#### FUNÇÃO DE COMANDO PRÉ DETERMINADO PARA REINICIAR PROCESSO FIREFOX, DEPOIS DE SELECIONADOS OS SIVS ####
Killall_firefox() {
	    while [ $resposta != "s" ]
	    do	
	        comando="sudo killall firefox"
	        alias_comando="Matar processo firefox"
	        clear
	        echo ""
	        echo -e "\e[7m------------------- >>  A T E N C Ã O  !!! << ------------------- \e[27m "
	        echo ""
	        echo -e "[5] VOLTAR"
	        echo ""
	        echo "Grupo selecionado:"
	        echo -e "   $grupo"
	        echo ""
	        echo ""
	        echo -ne "Continuar com o comando: $alias_comando ? (S/N) "
	        read resposta
	        resposta=$(echo $resposta|tr 'A-Z' 'a-z')
	            if [ $resposta = "5" -o $resposta = "n" ]
	            then
	                clear
	                echo -e "\e[7mVoltando ao menu anterior...\e[27m"
	                sleep 0.5
	                Selecionar_comando
	                clear
	            fi
	        clear
	    done
	Executar
}

#### FUNÇÃO PARA DIGITAR UM COMANDO NOS SIVS SELECIONADOS ####
Outro_comando() {
	    while [ $resposta != "s" ]
	    do
	        clear
	        echo ""
	        echo -e "[5] VOLTAR"
	        echo ""
	        echo -n "3. Digite o comando: "
	        read comando
	        #comando=$(echo $comando|tr 'A-Z' 'a-z')
	    if [ $comando = "5" ]
	    then
	        clear
	        echo -e "\e[7mVoltando ao menu anterior...\e[27m"
	        sleep 0.5
	        Selecionar_comando
	        clear
	    fi
    echo $comando |grep -q shutdown
        if [ $? -eq 0 ]
        then
	        clear
	        echo -e "\e[7mNao é possível executar este comando!\e[27m"
	        sleep 0.7
	        Outro_comando
	    fi
	clear
	echo ""
	echo -e "\e[7m------------------- >>  A T E N C Ã O  !!! << ------------------- \e[27m "
	echo ""
	echo "Grupo selecionado:"
	echo -e "   $grupo"
	echo ""
	echo ""
	echo -e "Voce digitou: $comando"
	echo ""
	echo -ne "O comando foi digitado corretamente? (S/N) "
	read resposta
	resposta=$(echo $resposta|tr 'A-Z' 'a-z')
	echo ""
	done
	Executar
}

#----------------------------------------------------------------------------------------------#
#----------------------------------------INÍCIO DO SCRIPT--------------------------------------#
#----------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------#

if [ -e /home/sbct/listas ]
then
    sudo touch /home/sbct/listas/Individual && sudo chmod 777 /home/sbct/listas/Individual
    Principal
else
    mkdir /home/sbct/listas
    sudo chmod -R 777 /home/sbct/listas
    Principal
fi
    exit 0
