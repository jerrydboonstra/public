#!/bin/bash
set -x 
shopt -s extglob

if [ $# -lt 1 ] ; then
 echo "usage: $0 buildNum"
 exit 1
fi
if [ ! -x /usr/bin/curl ] 
then
    echo "Cannot find /usr/bin/curl on this host.  Please install"
    exit 1
fi

# get remote file
/usr/bin/curl "http://127.0.0.1/hudson/view/_Apps/job/myapp-war/$1/artifact/myapp/target/myapp-0.1.zip" >> myapp-0.1-$1.zip
# mkdir
mkdir myapp-0.1-$1
cd myapp-0.1-$1
# unzip
unzip ../myapp-0.1-$1.zip
# chmod 
chmod 755 myapp.sh
exit 0
