# run this script as Sudo
TOMCAT_LIB=/usr/share/tomcat6/lib
if [ ! -w $TOMCAT_LIB ]
then
        echo "cannot write to $TOMCAT_LIB"
fi
TOMCAT_CONTEXT_DIR=/etc/tomcat6/Catalina/localhost
if [ ! -w $TOMCAT_CONTEXT_DIR ]
then
        echo "cannot write to $TOMCAT_CONTEXT_DIR"
fi
TOMCAT_ETC=/etc/tomcat6
if [ ! -w $TOMCAT_ETC ]
then
        echo "cannot write to $TOMCAT_ETC"
fi
cp ./usr/share/java/tomcat6/postgis-jdbc-1.5.2.jar $TOMCAT_LIB/.
cp ./usr/share/java/tomcat6/postgis-jdbc-1.5.2.jar $TOMCAT_LIB/.
cp ./usr/share/java/tomcat6/postgis-jdbc-jts-1.1.6.jar $TOMCAT_LIB/.
cp ./usr/share/java/tomcat6/postgresql-8.4-701.jdbc3.jar $TOMCAT_LIB/.
cp ./usr/share/java/tomcat6/tomcat-dbcp.jar $TOMCAT_LIB/.
cp ./usr/share/java/tomcat6/catalina-jmx-remote.jar $TOMCAT_LIB/.
chmod 644 $TOMCAT_LIB/postgis-jdbc-1.5.2.jar $TOMCAT_LIB/postgis-jdbc-jts-1.1.6.jar $TOMCAT_LIB/postgresql-8.4-701.jdbc3.jar $TOMCAT_LIB/tomcat-dbcp.jar $TOMCAT_LIB/catalina-jmx-remote.jar 

cp ./etc/tomcat6/Catalina/localhost/context.xml.default $TOMCAT_CONTEXT_DIR/.
cp ./etc/tomcat6/tomcat-users.xml $TOMCAT_ETC/.
cp ./etc/tomcat6/jmxremote.access $TOMCAT_ETC/.
cp ./etc/tomcat6/jmxremote.keystore $TOMCAT_ETC/.
cp ./etc/tomcat6/jmxremote.password $TOMCAT_ETC/.
cp ./etc/tomcat6/stuff-config.groovy $TOMCAT_ETC/.
cp ./etc/tomcat6/tomcat6.conf $TOMCAT_ETC/.
cp ./etc/tomcat6/server.xml $TOMCAT_ETC/.

chmod 644 $TOMCAT_CONTEXT_DIR/context.xml.default 
chown tomcat $TOMCAT_ETC/tomcat-users.xml 
chmod 640 $TOMCAT_ETC/tomcat-users.xml 
chown tomcat $TOMCAT_ETC/jmxremote.access
chmod 640 $TOMCAT_ETC/jmxremote.access
chown tomcat $TOMCAT_ETC/jmxremote.keystore
chmod 640 $TOMCAT_ETC/jmxremote.keystore
chown tomcat $TOMCAT_ETC/jmxremote.password
chmod 600 $TOMCAT_ETC/jmxremote.password
#chown tomcat $TOMCAT_ETC/myapp-config.groovy
#chmod 640 $TOMCAT_ETC/myapp-config.groovy
chown tomcat $TOMCAT_ETC/tomcat6.conf
chmod 640 $TOMCAT_ETC/tomcat6.conf
chown tomcat $TOMCAT_ETC/server.xml
chmod 640 $TOMCAT_ETC/server.xml

mkdir -p /Logs
chown tomcat /Logs

# temporary directories for image upload and resize, respectively
mkdir -p /tmp/myapp
chmod 777 /tmp/myapp
