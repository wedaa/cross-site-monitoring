#!/usr/bin/perl
#######################################################################
#
# Written by: Eric Wedaa (eric.wedaa@marist.edu)
# Last Modified on : 2015-09-09
#
#######################################################################
#
# Please only mention a host ONCE in the config file, and put all the 
# notifications for that host in the email section.  OTHERWISE
# if a host is down, the second and subsequent emails might not 
# be sent.
#
#######################################################################
#
#Sample crontab entry follows:
#
#5 * * * * /opt/monitor/bin/monitor.pl
#30 9 *  * 1 /opt/monitor/bin/monitor.pl testemail # Mails a test email to all entries
#
#######################################################################
#
#Please edit $config_dir, $storage_dir, and $localadminemail in the init routine.
#
#######################################################################
#
# This program requires the server to have perl, wget, and mailx installed.
#
#######################################################################

sub init {
	$config_dir="/opt/monitor";
	$storage_dir="/opt/monitor/storage/";
	chdir ("$storage_dir")|| die "Can not cd to $storage_dir, exiting now\n";
	#Send email to this local person when the whole network appears dead.O
	$localadminemail="name\@example.edu";  #MAKE SURE YOU use \@ (backslashAmpersand) and not just an ampersand
	$time_between_emails=(60*60*4)-10; # Number of seconds between emails (60 minutes*60 seconds*4 hours ) - 10 seconds
	my $wget=`which wget`;
	my $mailx=`which mailx`;
	if ($mailx eq ""){
		print "Can't find mailx, exiting now\n";
		exit;
	}
	if ($wget eq ""){
		print "Can't find wget, exiting now\n";
		exit;
	}
}

sub check_internet {
	`touch www.google.com`;
	unlink ("www.google.com");
	`wget http://www.google.com -O www.google.com -o /dev/null`;
	my $size = -s "www.google.com";
	if ($size < 100){ #Bad things are happening
		print "Bad things are happening, can't get to google\n";
		`mailx -s \"Can't contact google, is the internet down?\" $localadminemail </dev/null`;
		exit 1;
	}

}

sub test_email{
	my $hostname = `hostname`;
	my $host_array;
	chomp $hostname;
	open (FILE, "$config_dir/monitor.conf")|| die "Can not read $config_dir/monitor.conf.  Exiting now\n";
	while (<FILE>){
		chomp;
		($host,$email)=split (/\s+/,$_);
		if ( $host_array{$host} == 1 ){
			print "$host has already been tested, email to $email might not be sent\n";
			`mailx -s \"$host has already been tested, email to $email might not be sent\" $localadminemail </dev/null`;
		}
		else {
			$host_array{$host}=1;
		}
		if (/http:\/\//){
			$file = $host;
			$file =~ s/http:\/\///;
			open (OUTPUT_FILE, ">test_outbound_email_$file");
			print (OUTPUT_FILE "\n");
			print (OUTPUT_FILE "This mail is from $0 at $hostname.\n");
			print (OUTPUT_FILE "\n");
			print (OUTPUT_FILE "This email is confirm remote monitoring is working for host $host .\n");
			print (OUTPUT_FILE "\n");
			print (OUTPUT_FILE "Please contact $localadminemail if you want to remove this test permanently.\n");
			print (OUTPUT_FILE "\n");
			close (OUTPUT_FILE);
			`mailx -s \"Weekly monitoring test email for $host\" $email <test_outbound_email_$file`;
		}
	}
	close (FILE);

}

sub do_it{
	my $host;
	my $email;
	my $file;
	my $hostname;
	my $seconds_since_modified;
	my $host_array;

	$hostname = `hostname`;
	chomp $hostname;
	open (FILE, "$config_dir/monitor.conf")|| die "Can not read $config_dir/monitor.conf.  Exiting now\n";
	while (<FILE>){
		chomp;
		($host,$email)=split (/\s+/,$_);
		print "host is $host, email is $email\n";
		if ( $host_array{$host} == 1 ){
			print "$host has already been tested, email to $email might not be sent\n";
			`mailx -s \"$host has already been tested, email to $email might not be sent\" $localadminemail </dev/null`;
		}
		else {
			$host_array{$host}=1;
		}
		if (/http:\/\//){
			$file = $host;
			$file =~ s/http:\/\///;
			`touch $file`;
			unlink ("$file");
			`wget $host -O $file -o /dev/null`;
			my $size = -s "$file";
			if ($size < 100){ #Bad things are happening
				print "Bad things are happening at $host\n";
				$seconds_since_modified = 86400 * -M "outbound_email_$file";
				print "seconds are $seconds_since_modified\n";
				if ( ($seconds_since_modified < 1 ) || ($seconds_since_modified > $time_between_emails )){
					#send email
					print "Bad things are happening at $host\n";
					open (OUTPUT_FILE, ">outbound_email_$file");
					print (OUTPUT_FILE "\n");
					print (OUTPUT_FILE "This mail is from $0 at $hostname.\n");
					print (OUTPUT_FILE "\n");
					print (OUTPUT_FILE "Your host $host may be down.  $0 detected a webpage less than 100 bytes(It was $size bytes long).\n");
					print (OUTPUT_FILE "\n");
					print (OUTPUT_FILE "Please contact $localadminemail if you want to remove this test permanently.\n");
					print (OUTPUT_FILE "\n");
					close (OUTPUT_FILE);
					`mailx -s \"Can't contact $host, is it down?\" $email <outbound_email_$file`;
				}
			}
		}
	}
	close (FILE);

}

my $time_between_emails;
&init;
&check_internet;
$option=shift;
if ($option eq "testemail"){
	&test_email;
}
else {
	&do_it;
}
