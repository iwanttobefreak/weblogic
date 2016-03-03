#!/bin/bash

# Descarga de JVM
curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" \
-b 'oraclelicense=accept-dbindex-cookie' \
-OL http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz

#Instalacion JVM
mkdir /u01/jdk
mkdir /u01/software
mv jdk-7u79-linux-x64.tar.gz /u01/software
tar -xzvf /u01/software/jdk-7u79-linux-x64.tar.gz -C /u01/jdk
#rm jdk-7u79-linux-x64.tar.gz
ln -s /u01/jdk/jdk1.7.0_79 /u01/java



usuario=
contrasenya=
download=http://download.oracle.com/otn/nt/middleware/11g/wls/1036/wls1036_generic.jar

Site2pstoreToken=`curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" "http://www.oracle.com/webapps/redirect/signon?nexturl=https://www.oracle.com/technetwork/indexes/downloads/index.html" | grep Site2pstoreToken | awk -F\= {'print  $3'} | awk -F\" {'print $1'}`

curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0"  \
-d 'ssousername='$usuario'&password='$contrasenya'&site2pstoretoken='$Site2pstoreToken \
-o /dev/null \
https://login.oracle.com/sso/auth -c cookie

echo '.oracle.com       TRUE    /       FALSE   0       oraclelicense   accept-dbindex-cookie' >> cookie

curl -A "Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0 Iceweasel/38.6.0" \
-b cookie \
-OL $download
