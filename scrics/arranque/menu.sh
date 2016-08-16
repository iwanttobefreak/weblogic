#!/bin/bash
#source menu.env
weblogic_servers=( admin managed )
echo ${weblogic_servers[1]}
echo "hola"
#exit 0


verd(){
echo -e '\033[1;37m\033[42m'"$1"
}
rojo(){
echo -e '\033[1;37m\033[41m'"$1"
}
azul(){
echo -e '\033[1;37m\033[46m'"$1"
}

incorrect_option () {
echo "Option not avalilable"
pausa
}
exit_menu () {
echo "Exiting Menu "$1
pausa
}

clear
pausa() {
echo
echo "Press INTRO to continue"
read a
}
menu_principal() {
selection=
until [ "$selection" = "0" ]; do
clear
echo " "
echo "======================================================================"
echo -e "\033[1m MENU OF $(hostname) - Date: $(date) \033[0m"
tput sgr0
echo "======================================================================"
echo -e '\E[47;31m'
echo " ADMINISTRATION MENU"
tput sgr0
echo
echo " 0 - Exit menu   "
echo " 1 - Weblogic "
echo " 2 - OHS "
tput sgr0
echo "======================================================================"
echo -n " Opcion: "
read selection
echo " "
op=''
case $selection in
0 ) exit_menu ;;
1 ) menu_weblogic;;
2 ) menu_ohs;;
* ) incorrect_option    ;;
esac
done
}
menu_weblogic() {
selection=
until [ "$selection" = "0" ]; do
clear
echo " "
echo "======================================================================"
echo -e "\033[1m MENU OF $(hostname) - Date: $(date) \033[0m"
tput sgr0
echo "======================================================================"
echo -e '\E[47;31m'
echo " ADMINISTRATION MENU WEBLOGIC "
tput sgr0
echo
echo " 0 - Return to main menu   "
for (( i = 1 ; i <= ${#weblogic_servers[@]} ; i++ ))
do
  echo " "$i" - "${weblogic_servers[$i-1]}
done
tput sgr0
echo "======================================================================"
echo -n " Opcion: "
read selection
echo " "
op=''
case $selection in
0 ) menu_principal ;;
* ) if [ "$selection" == "" ] || [ $selection -gt ${#weblogic_servers[@]} ];then incorrect_option; else weblogic ${weblogic_servers[$selection-1]};fi    ;;
esac
done
}

menu_ohs() {
selection=
until [ "$selection" = "0" ]; do
clear
echo " "
echo "======================================================================"
echo -e "\033[1m MENU OF $(hostname) - Date: $(date) \033[0m"
tput sgr0
echo "======================================================================"
echo -e '\E[47;31m'
echo " ADMINISTRATION MENU OHS "
tput sgr0
echo
echo " 0 - Return to main menu   "
for (( i = 1 ; i <= ${#ohs_servers[@]} ; i++ ))
do
  echo " "$i" - "${ohs_servers[$i-1]}
done
tput sgr0
echo "======================================================================"
echo -n " Opcion: "
read selection
echo " "
op=''
case $selection in
0 ) menu_principal ;;
* ) if [ "$selection" == "" ] || [ $selection -gt ${#ohs_servers[@]} ];then incorrect_option; else ohs ${ohs_servers[$selection-1]};fi    ;;
esac
done
}

weblogic() {
menu=$1
until [ "$op" = "0" ]; do
clear
echo " "
echo "======================================================================"
echo -e "\033[1m MENU DE $(hostname) - Date: $(date) \033[0m"
tput sgr0
echo "======================================================================"
echo
echo -e '\E[47;31m'" MENU ${menu} "`tput sgr0`
echo
echo " 0 - Return to weblogic Menu "
verd " 1 - Start ${menu}   "
rojo " 2 - Stop ${menu}    "
azul " 3 - Status ${menu}  "
tput sgr0
echo
echo "======================================================================"
echo -n " Option: "
read op
echo " "
case $op in
0 ) exit_menu ${menu};;
1 ) echo -n "Are you sure (y/n)?";read a; if [ "$a" == "y" ];then /usr/bin/sudo /bin/su - weblogic -c /oracle/scripts/start_${menu}.sh;else echo "Abort";fi;pausa;;
2 ) echo -n "Are you sure (y/n)?";read a; if [ "$a" == "y" ];then /usr/bin/sudo /bin/su - weblogic -c /oracle/scripts/stop_${menu}.sh;else echo "Abort";fi;pausa;; 
3 ) ps -fC java | grep --color=auto Name=${menu}; if [ $? -eq 1 ];then echo "There are no process with weblogic server "${menu};fi;pausa;;
* ) incorrect_option;;
esac
done
}

ohs() {
menu=$1
until [ "$op" = "0" ]; do
clear
echo " "
echo "======================================================================"
echo -e "\033[1m MENU DE $(hostname) - Date: $(date) \033[0m"
tput sgr0
echo "======================================================================"
echo
echo -e '\E[47;31m'" MENU ${menu} "`tput sgr0`
echo
echo " 0 - Return to OHS Menu "
verd " 1 - Start ${menu}   "
rojo " 2 - Stop ${menu}    "
azul " 3 - Status ${menu}  "
tput sgr0
echo
echo "======================================================================"
echo -n " Option: "
read op
echo " "
case $op in
0 ) exit_menu ${menu};;
1 ) echo -n "Are you sure (y/n)?";read a; if [ "$a" == "y" ];then /usr/bin/sudo /bin/su - weblogic -c /oracle/scripts/start_${menu}.sh;else echo "Abort";fi;pausa;;
2 ) echo -n "Are you sure (y/n)?";read a; if [ "$a" == "y" ];then /usr/bin/sudo /bin/su - weblogic -c /oracle/scripts/stop_${menu}.sh;else echo "Abort";fi;pausa;;
3 ) ps -fC httpd.worker | head -2 | grep --color=auto /${menu}/ ; if [ $? -eq 1 ];then echo "There are no process with ohs server "${menu};fi;pausa;;
* ) incorrect_option;;
esac
done
}


menu_principal
