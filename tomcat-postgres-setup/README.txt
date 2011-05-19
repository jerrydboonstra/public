Steps to launch a new Elastic Beanstalk instance:

1. Go to AWS EB console and Launch a new environment filling in the following params:
- security key: 
2. Switch to EC2 pane, US East region, watch for new instance
3. Capture public IP of new instance
4. create ~/.ssh/config entry for new host, to allow password-less login to host

Change directories to where 'maketar.sh' lives
5. ./maketar.sh
6. scp myapp.tgz $NEW_SSH_HOSTNAME:~/.
7. ssh $NEW_SSH_HOSTNAME
# tar xvf myapp.tgz
# cd myapp
# sudo ./install.sh
# sudo /etc/init.d/tomcat6 restart
# tail -f /Logs/myapp_info.log /var/log/tomcat6/tail_catalina.log
