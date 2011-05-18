# How to securely connect to a remote Tomcat 6 server with JMX

This was difficult to figure out.

## Preparation

### Prepare jmxremote.access

1. Create file `jmxremote.access`, containing

        observer readonly
        admin readwrite

### Prepare jmxremote.password

1. Create file `jmxremote.password`, containing

        observer dov2ov8at4ic2yi
        admin liv7ti2ows2ab5n

## Tomcat server setup

<big>On Tomcat Server,</big>

### Put new files in Place

1. copy jmxremote.access and jmxremote.password to `/etc/tomcat6/.`
1. __important__ Set permissions on `/etc/tomcat6/jmxremote.password` to 600
1. Acquire `catalina-jmx-remote.jar`, which is required by Tomcat.  I found it here: http://apache.opensourceresources.org/tomcat/tomcat-6/v6.0.32/bin/extras/

### Change Tomcat configuration

#### Add to CATALINA_OPTS

1. Add to `/etc/tomcat6/tomcat6.conf`:

        CATALINA_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=localhost \
            -Dcom.sun.management.jmxremote.password.file=/etc/tomcat6/jmxremote.password \
            -Dcom.sun.management.jmxremote.access.file=/etc/tomcat6/jmxremote.access"

`Djava.rmi.server.hostname=localhost` is necessary so the RMI registry lookups give out addresses
on localhost on the server, otherwise it will give out public addresses blocked by the firewall.

#### Add to server.xml

1. Add the following to `/etc/tomcat6/server.xml`

        <Listener className="org.apache.catalina.mbeans.JmxRemoteLifecycleListener"
                    rmiRegistryPortPlatform="9413" rmiServerPortPlatform="9412" />

The port numbers are arbitrary.  If this step is not done, the RMI registry will give out RMI
ports at a random port location, making SSH tunnelling or passing through a production firewall
nearly impossible.  This step 'pins' the port to a predetermined number, which we can then tunnel through.

#### Add jar

1. Copy `catalina-jmx-remote.jar` to /usr/share/tomcat6/lib/. and ensure it is readable by Tomcat.

#### Finish up server setup

1. Restart Tomcat: `sudo /etc/init.d/tomcat6 restart`

## Client setup

### Setup SSH tunnel scripts

1. Make sure you can already SSH into the remote host without a password.
1. Create a script `tunnel-$HOSTNAME-jndi.sh` and chmod 755, containing, where $HOSTNAME is the literal hostname that works for ssh'ing:

        ssh $HOSTNAME -L localhost:9413:localhost:9413

1. Create a script `tunnel-$HOSTNAME-jmx.sh` and chmod 755, containing, where $HOSTNAME is the literal hostname that works for ssh'ing:

        ssh $HOSTNAME -L localhost:9412:localhost:9412

1. Create two new terminal windows and run one script in each, leaving them logged in as long as you
want the tunnels to stay up.  Exit the terminal sessions to close the tunnels: its always smart to
close all applications using the tunnels first.

### Running VisualVM

This is only tested with Visual VM.  I'm using VisualVM which ships with Mac OS X 10.6.  Invoke with `jvisualvm` on the command line.

1. Launch VisualVM and Create a New JMX Connection
2. Use the following connection address: `service:jmx:rmi://127.0.0.1:9412/jndi/rmi://127.0.0.1:9413/jmxrmi`
3. Use either of the username/passwords as specified in jmxremote.* files

Viola!

## References

http://tomcat.apache.org/tomcat-6.0-doc/config/listeners.html
