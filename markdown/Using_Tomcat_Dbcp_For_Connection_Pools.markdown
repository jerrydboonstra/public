# Using Tomcat DBCP for Connection Pools

These steps describe modifying your Grails application for production deployment to Tomcat 6, using Tomcat DBCP to manage database connection pools.  

This allows your application to be (re)deployed to Tomcat without errors like 

    SEVERE: The web application [] registered the JDBC driver [com.mysql.jdbc.Driver] 
    but failed to unregister it when the web application was stopped. To prevent a memory 
    leak, the JDBC Driver has been forcibly unregistered.

## Overview

The steps will be:

1. Add new jars to Tomcat installation to allow it to hold database pools
1. Add configuration to Tomcat to direct it to create a specific database pool
1. Modify your Grails webapp to not ship jars duplicated in Tomcat
1. Put it all together

## Collect materials

1. Identify a list of jars which would be required by Tomcat to create and manage a database connection pool without your webapp running.  I'm using Postgres and Postgis, so my list is:

<ul>
- postgresql-8.4-701.jdbc3.jar
- postgis-jdbc-1.5.2.jar
- postgis-jdbc-jts-1.1.6.jar
</ul>

1. Acquire tomcat-dbcp.jar I found this distributed as part of Grails 1.3.7 Tomcat plugin:

    ~/.grails/1.3.7/projects/trunk/plugins/tomcat-1.3.7/lib/tomcat-dbcp.jar 

1. Create context.xml.default

Typically you can ship a "META-INF/context.xml" in your War file and it will be used by the Tomcat installation.  When deploying on ElasticBeanstalk, the deployer repackages your war file as ROOT.war to run it as the ROOT context, which seems to defeat pick up of the META-INF/context.xml.  Since Tomcat will also recognize a `/etc/tomcat6/Catalina/localhost/context.xml.template` file deployed manually as the context.xml for every webapp it hosts, I'm using that method.

Mine looks like this.  The important part is the "Resource" element, which defines a pooled datasource available via JNDI. There are hardcoded URLs, cleartext username and password here.

    <?xml version="1.0" encoding="UTF-8"?>
    <!-- http://tomcat.apache.org/tomcat-6.0-doc/config/context.html -->
    <!-- asserting swallowOutput means the bytes output to System.out and System.err
            by the web application will be redirected to the web application logger -->
    <Context antiResourceLocking="false" clearReferencesStopTimerThreads="true"
        swallowOutput="true" workDir="/tmp/myapp">

            <!--  Postgres JDBC driver jar must be in Tomcat appbase /lib for this to work -->
            <Resource name="jdbc/myapp" auth="Container" type="javax.sql.DataSource"
                    maxActive="8" maxIdle="4" username="user" password="pass"
                    driverClassName="org.postgis.DriverWrapper" 
                    dialect="org.hibernatespatial.postgis.PostgisDialect"
                    url="jdbc:postgresql://127.0.0.1/mydb" />

            <!-- Disable peristance of sessions across appserver restarts -->
            <Manager className="org.apache.catalina.session.StandardManager" pathname="" />
    </Context>

## Update your Grails app

For reasons I won't get into here, any jars that were added to the Tomcat classpath cannot be duplicated in your webapp.  I'm assuming most Grails webapps will use non-JNDI datasources for development and testing, and only have Tomcat manage db connections when built with the 'production' environment.  Therefore the deployed war will need to exclude the database jars.

### Update BuildConfig.groovy

I have this block in my BuildConfig after the dependencies block.  It excludes the pool jars from my production war at Build time.

    // Postgres and Postgis jars must be
    // in /usr/share/tomcat6/lib and NOT included in the war file.
    // Soln:
    // http://www.anyware.co.uk/2005/2009/01/21/excluding-files-from-a-war-with-grails-the-right-way/
    // If you have an application that needs to exclude one or more resources, you
    // can do this in BuildConfig.groovy just by supplying a closure that uses Ant calls
    // to delete the resources, in the grails.war.resources property:
    // Remove the JDBC jar before the war is bundled
    grails.war.resources = { stagingDir ->
        if (Environment.current == Environment.PRODUCTION) { // allow other phases to use war commands
            println "Removing JDBC JARs from ${stagingDir}, which are provided by Container"
            delete(file:"${stagingDir}/WEB-INF/lib/postgis-jdbc-1.5.2.jar")
            delete(file:"${stagingDir}/WEB-INF/lib/postgis-jdbc-jts-1.1.6.jar")
            delete(file:"${stagingDir}/WEB-INF/lib/postgresql-8.4-701.jdbc3.jar")
        }
    }

### Use the right datasource

You'll want to redefine your production datasource to use the JNDI resource. 
Update DataSource.groovy 
    production {
        dataSource {
            pooled = false
            jndiName = "java:comp/env/jdbc/myapp"
            loggingSql = false
        }
    }

Note that `jndiName = "java:comp/env/$RESOURCE_NAME"`, where $RESOURCE_NAME is the name attribute of the Resources element from `context.xml.default`

## Deployment

Putting it all together, this assumes you are starting with a fresh Tomcat with no deployed apps.

1. On your remote deployment box, copy the jars from the first step into Tomcat's lib dir.  For ElasticBeanstalk this is at `/usr/share/tomcat6/lib`.  Ensure that they are readable by Tomcat.
1. On your remote deployment box, copy `context.xml.template` into `/etc/tomcat6/Catalina/localhost/context.xml.template`
1. (Re)start your remote Tomcat: `sudo /etc/init.d/tomcat6 restart`. You can monitor startup with `tail -f /var/log/tomcat6/catalina.log`
1. Deploy your webapp to Tomcat.  It should start as normal.
1. Redeploy your webapp to Tomcat.  It should restart as normal.

