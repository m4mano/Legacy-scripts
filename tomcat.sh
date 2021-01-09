#! /bin/sh
# chkconfig: 2345 89 11
# BEGIN INIT INFO
# Required-Start: $local_fs
# Required-Stop: $local_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
#  updated by - Manoj 
# Short-Description: Script for Apache & Tomcat start/stop
# Description: apache is  open-source cross-platform web server software
 
# Defining Variables
DATE_T=`date +%m%d%Y_%H%M%S`
echo "Invoking Apache & Tomcat start/stop script at `hostname`" > /tmp/${DATE_T}_apache_startstop.log
#LOGFILE= /tmp/${DATE_T}_apache_startstop.log
 
# Script Execution
case $1 in
start|START|Start)
 
#ID Availability Check
 
usradmin_id_chk() {
uid=`id -u usradmin`
        if [ "$uid" = 06932 ]; then #this UID could be incorrect
             echo "The usradmin ID is now available" >> /tmp/${DATE_T}_apache_startstop.log
                                        return 1
                else
                                          echo "The usradmin ID is still not yet available" >> /tmp/${DATE_T}_apache_startstop.log
                return 0
fi
}
while usradmin_id_chk
do
sleep 20
done
 
#Apache Start-up
{
for apache in `find /app/*/bin/apachectl* -type f`
do
/bin/su usradmin -c "${apache} start &"
done
} 2>&1 | tee -a /tmp/${DATE_T}_apache_startstop.log
touch /var/lock/subsys/apache
 
#Tomcat Start-up
{
        for tomcat in `find /app/tomcat*/*/bin/startup.sh -type f`
                do
                /bin/su usradmin -c "${tomcat} &"
                done
                                } 2>&1 | tee -a /tmp/${DATE_T}_apache_startstop.log
touch /var/lock/subsys/tomcat
;;
 
stop|STOP|Stop)
 
#Apache ShutDown
{
for apache in `find /app/*/bin/apachectl* -type f`
do
/bin/su usradmin -c "${apache} stop &"
done
} 2>&1 | tee -a /tmp/${DATE_T}_apache_startstop.log
rm -f /var/lock/subsys/apache
#Tomcat ShutDown
{
for tomcat in `find /app/tomcat*/*/bin/shutdown.sh -type f`
do
/bin/su usradmin -c "${tomcat} &"
done
} 2>&1 | tee -a /tmp/${DATE_T}_apache_startstop.log
rm -f /var/lock/subsys/tomcat
;;
 
esac
chmod 777 /tmp/${DATE_T}_apache_startstop.log
