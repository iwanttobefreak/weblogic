#!/bin/bash
#Variables
# Carpeta descarga software
v_descarga_software=/u01/software
v_ruta_binarios=/u01/middleware1036
v_java=/u01/java/bin/java




mkdir $v_descarga_software
cd /u01/software

# Descarga de JVM
curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" \
-b 'oraclelicense=accept-dbindex-cookie' \
-OL http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz

#Descarga de Weblogic 10.3.6
read -p "Oracle User:" v_usuario_oracle
read -s -p "Password:" v_contrasenya_oracle

v_cookie=/tmp/$$_cookie
v_download=http://download.oracle.com/otn/nt/middleware/11g/wls/1036/wls1036_generic.jar

v_Site2pstoreToken=`curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" "http://www.oracle.com/webapps/redirect/signon?nexturl=https://www.oracle.com/technetwork/indexes/downloads/index.html" | grep Site2pstoreToken | awk -F\= {'print  $3'} | awk -F\" {'print $1'}`

curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0"  \
-d 'ssousername='$usuario'&v_usuario_oracle='$v_contrasenya_oracle'&site2pstoretoken='$v_Site2pstoreToken \
-o /dev/null \
https://login.oracle.com/sso/auth -c $v_cookie

echo '.oracle.com	TRUE	/	FALSE	0	oraclelicense	accept-dbindex-cookie' >> $v_cookie

curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" \
-b $v_cookie \
-OL $v_download

#Instalacion JVM
mkdir /u01/jdk
tar -xzvf /u01/software/jdk-7u79-linux-x64.tar.gz -C /u01/jdk
ln -s /u01/jdk/jdk1.7.0_79 /u01/java

#Instalación Weblogic
v_software=/u01/software/wls1036_generic.jar
v_tmp_silent=/tmp/$$_silent.xml

echo '<?xml version="1.0" encoding="UTF-8"?>
<domain-template-descriptor>

<input-fields>
   <data-value name="BEAHOME"                   value="'$v_ruta_binarios'" />
   <data-value name="USER_INSTALL_DIR"          value="'$v_ruta_binarios'" />
   <data-value name="INSTALL_NODE_MANAGER_SERVICE"   value="no" />
   <data-value name="COMPONENT_PATHS" value="WebLogic Server" />
</input-fields>
</domain-template-descriptor>' > $v_tmp_silent

$v_java -jar $v_software -mode=silent -silent_xml=$v_tmp_silent

# Creación  del dominio
curl -s -o template1036.jar -k "https://wiki.legido.com/lib/exe/fetch.php?media=informatica:weblogic:template.jar"

v_template=/u01/software/template1036.jar
v_ruta_dominio=/u01/domains
v_nou_template=/tmp/$$_nou_template.jar
source $v_ruta_binarios/wlserver_10.3/server/bin/setWLSEnv.sh
v_nombre_dominio=prueba

read -p "Usuario admin [weblogic]:" v_weblogic_user
read -s -p "Password:" v_weblogic_password

$java weblogic.WLST <<EOF
readTemplate('$v_template')
set('Name','$v_nombre_dominio')
writeTemplate('$v_nou_template')
closeTemplate()
createDomain('$v_nou_template','$v_ruta_dominio/$v_nombre_dominio','$v_weblogic_user','$v_weblogic_password)
exit()
EOF

