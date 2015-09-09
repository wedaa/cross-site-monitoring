README for cross-site-monitoring
==============

WHAT IS THIS?
--------------
This is a dirt-simple remote monitoring script.  ALL IT DOES
is do a wget to make sure your website is up, and if the file
is less than 100 bytes long, it will email you.

It also is smart enough to only email you every four hours so 
you aren't flooded with alerts.  (That's configurable in the 
script too.)

Run this at some cheap cloud-provider site and you have remote 
monitoring for your websites that you control entirely.

WARNING
--------------
This code works for me.  Whether it works for you is another 
question.  It should.

Written By
--------------
Written by: Eric Wedaa (eric.wedaa@marist.edu)
Last Modified on : 2015-09-09

External software required
--------------
You need to have bash, perl, wget, and mailx installed to run this program

How to install
--------------
1) Edit monitor.pl for  $config_dir, $storage_dir, and $localadminemail in the init routine.
2) run ./install.sh
3) Edit /opt/monitor/monitor.conf for the hosts to be monitored and where to send the email alerts
4) Add the crontab entries to your crontab.  Please note that this user must be able to edit and delete files in /opt/monitor/storage.

Crontab Entries
--------------

	5 * * * * /opt/monitor/bin/monitor.pl # You can run this more often if you want!
	30 9 *  * 1 /opt/monitor/bin/monitor.pl testemail # Mails a test email to all entries

Notes on monitor.conf
--------------
Please only mention a host ONCE in the config file, and put all the 
notifications for that host in the email section.  OTHERWISE
if a host is down, the second and subsequent emails might not 
be sent.
