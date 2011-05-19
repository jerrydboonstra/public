    // Add this block to BuildConfig.groovy after dependencies block

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

