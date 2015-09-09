#!/bin/sh

echo "You need to edit monitor.pl  Please see monitor.pl for details"
echo ""
echo "You need to edit this file for OWNER."
echo ""
echo "And then comment out the exit statement"

exit

OWNER="wedaa" # What is the owner of the process running LongTail?

# DO NOT EDIT BELOW THIS LINE
# I'm sorry, there is still stuff hard-coded in the programs
# that reference these locations.
echo ""
echo "#############################################################"
echo "Checking for OS"
echo ""
RHEL=0

if [ -e /etc/redhat-release ] ; then
	echo "This seems to be a RedHat based system"
	RHEL=1
fi
if [ -e /etc/fedora-release ] ; then
	echo "This seems to be a RedHat/Fedora based system"
	RHEL=1
fi
if [ -e /etc/centos-release ] ; then
	echo "This seems to be a RedHat/Centos based system"
	RHEL=1
fi
echo ""
echo ""
echo "#############################################################"
echo "Checking for which command"
echo ""

which ls >/dev/null 2>&1
LAST=$?
if [ $LAST -ne 0 ] ; then
	echo ""
	echo "'which' command not found, can't continue"
	echo "If this is a RedHat based system, please try"
	echo "   yum install which"
	echo "Then run this program again"
	echo ""
	exit
fi

SCRIPT_DIR="/opt/monitor/"    # Where do we put the scripts?
STORAGE_DIR="/opt/monitor/storage"    # Where do we put the scripts?

echo ""
echo "#############################################################"
echo "Checking to see that $OWNER already exists"
echo ""

echo ""
if id -u "$OWNER" >/dev/null 2>&1; then
	echo "user $OWNER exists, this is good"
else
	echo "user $OWNER does not exist, this is bad"
	echo "Please create the user and re-run this script"
	echo ""
	exit
fi

echo ""
echo "#############################################################"
echo "Making dirs now"
echo ""

OTHER_DIRS="$SCRIPT_DIR $STORAGE_DIR"

for dir in $OTHER_DIRS ; do
	if [ -e $dir ] ; then
		if [ -d $dir ] ; then
			echo "$dir allready exists, this is a good thing"
		else
			echo "$dir allready exists but is not a directory"
			echo "This is a bad thing, exiting now!"
			exit
		fi
	else
		mkdir -p $dir
		chown $OWNER $dir
		chmod a+rx $dir
	fi
done

#
# Check for required software here
#
echo ""
echo "#############################################################"
echo "Checking for required programs now"
echo ""
for i in perl wget mailx ; do
	echo -n "Checking for $i...  "
	which $i >/dev/null
	if [ $? -eq 0 ]; then
		echo "$i found"
	else
		echo "$i not found, you need to install this"
	fi
done

echo ""
echo "#############################################################"
echo "Copying files to /opt/monitor now"
echo ""

ETC_FILES="monitor.pl monitor.conf"

for file in $ETC_FILES ; do
	echo $file
  cp $file $SCRIPT_DIR
  chmod a+r $SCRIPT_DIR/$file
  chown $OWNER $SCRIPT_DIR/$file
done
chmod a+rx $SCRIPT_DIR/monitor.pl 


echo "#############################################################"
echo ""
echo ""
echo "Please add the entries from sample.crontab to your crontab file"
echo ""
echo "5 * * * * /opt/monitor/bin/monitor.pl"
echo "30 9 *  * 1 /opt/monitor/bin/monitor.pl testemail # Mails a test email to all entries"

echo ""
echo "#############################################################"
echo ""
echo ""
echo "Please run "
echo "      /opt/monitor/monitor.pl "
echo "      /opt/monitor/monitor.pl testemail"
echo "to test your installation"
echo ""
echo "#############################################################"
echo ""
