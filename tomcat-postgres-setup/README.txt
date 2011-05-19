Steps to customize a new Elastic Beanstalk instance

Use this at the "customization" step of 
http://blog.jetztgrad.net/2011/02/how-to-customize-an-amazon-elastic-beanstalk-instance/
to allow EB autoscaling / monitoring to work.

Based on ami-80c438e9
which is Tomcat 6 32-bit

0. Acquiring running instance per Blog above
1. Capture public IP of instance
2. create ~/.ssh/config entry for new host, to allow password-less login to host

Change directories to where 'maketar.sh' lives
3. ./maketar.sh
4. scp myapp.tgz $NEW_SSH_HOSTNAME:~/.
5. ssh $NEW_SSH_HOSTNAME
# tar xvf myapp.tgz
# cd myapp
# sudo ./install.sh
# sudo /etc/init.d/tomcat6 restart
# tail -f /Logs/myapp_info.log /var/log/tomcat6/tail_catalina.log

This host is now ready to be used as the basis for a custom AMI snapshot.
