#!/usr/bin/perl
#use POSIX qw(strftime);
use strict;
use Glib qw/TRUE FALSE/; 
use LWP::Simple qw($ua getstore get is_success);

my $xbmcoldwebserver="localhost:8080";


my $WIFIFLAG=0;
my $ETHFLAG=0;
my $MOVIEFLAG=0;
my $NOTIFSUSPFLAG=0;

my $SUSPFILE="/home/antonio/bin/ethkillwifi.disable";
my @abbr;
my $DEBUG=1;
my $MOVIEPATTERN="XBMC";
my $moviepid;
my $cpup;

$SIG{INT} = sub { die "Caught a sigint $!" };

#auto eth0
#iface eth0 inet static
#address 192.168.0.5
#netmask 255.255.255.0
#gateway 192.168.0.1
#dns-nameservers 192.168.0.1

#cat  /sys/class/net/eth0/operstate

# sudo route del -net 192.168.0.0 netmask 255.255.255.0 dev wlan0
# sudo route add default gw 192.168.0.1 eth0
#Kernel IP routing table
#Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
#default         avtablet.local  0.0.0.0         UG    0      0        0 eth0
#192.168.0.0     *               255.255.255.0   U     0      0        0 eth0
	 
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900; ## $year contains no. of years since 1900, to add 1900 to make Y2K compliant
@abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

#print "$abbr[$mon] $mday $hour:$min:$sec";

sleep(3);

 my $wifistat=`ifconfig | grep wlan | grep 192.168 |tr -d " "`;
 my $ethstat=`cat  /sys/class/net/eth0/operstate`;
 my $moviestat="";


for(;;){
	sleep(3);
	 if (-e $SUSPFILE) {
		if ( $DEBUG == 1 ) {
			print "Eth mon disabled...\n";
			
		}
		
		if ($NOTIFSUSPFLAG == 0) {
			$NOTIFSUSPFLAG =1;
			system("notify-send \"Eth Mon\" \"Disabled!\"");
		}
		sleep (30);
		next;
	} else {
		$NOTIFSUSPFLAG =0;
	}
	

	 $moviestat=checkxbmc();
	# $moviestat=1;
	
	 
	 #print  $cpup;exit;
	 
	 $ethstat=`cat  /sys/class/net/eth0/operstate`;
	 chomp($ethstat); 
	 
	$wifistat=`ifconfig wlan0|grep 192.168|tr -d " "`;

	if ( "$wifistat" eq "" ) {
		$WIFIFLAG=0;
	} else {
		$WIFIFLAG=1;
	}
	
	if ( "$ethstat" eq "down" ) {
		$ETHFLAG=0;
	} else {
		$ETHFLAG=1;
	}	
	#print $WIFIFLAG ,"--",$ETHFLAG,"--",$ethstat;
	
	if ( ("$ethstat" eq "up" && $WIFIFLAG == 0) || ($WIFIFLAG == 1 && "$ethstat" eq "down" && $MOVIEFLAG == 1) ) {
		if ( $DEBUG == 1 ) {
			print "Nothing to do...\n";
		}
		
		next;
	} 
	
	if ( $DEBUG == 1 ) {
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900; ## $year contains no. of years since 1900, to add 1900 to make Y2K compliant
		@abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
		print  "$abbr[$mon] $mday $hour:$min:$sec ","W $WIFIFLAG - E $ETHFLAG\n";
	}
	
	if ( $moviestat && $MOVIEFLAG == 0) {
		$MOVIEFLAG=1;
		print "Video Playing, waiting for second check...\n";
		sleep (600);
		$moviestat=checkxbmc();
		if ( $moviestat  ) {
			system("notify-send \"Moview Watching!\" \"Disabling WIFI card!\"");
			system("nmcli -p con down id avnetwork ");
			system("sudo /sbin/iwconfig wlan0 txpower off");
			
			sleep(5);
		}
	} elsif (!$moviestat && $MOVIEFLAG == 1) {
		system("notify-send \"Moview Watching Done!\" \"Remenber WIFI card is disabled!\"");
		$MOVIEFLAG=0;
	}
	chomp($ethstat);
	if ( "$ethstat" eq "down" && $WIFIFLAG == 0 && $MOVIEFLAG == 0) {
		if ( $DEBUG == 1 ) {
			print  "$abbr[$mon] $mday $hour:$min:$sec ","Wifi On\n$ethstat\n";
		}
		system("notify-send \"Wired Network down\" \"Enabling WIFI card!\"");
		#system("sudo route del -net 192.168.0.0 netmask 255.255.255.0 dev eth0");
		system("sudo /sbin/iwconfig wlan0 txpower on");
		system("nmcli -p con up id avnetwork iface wlan0");

		sleep(5);
		
		$WIFIFLAG=1;
		$ETHFLAG=0;
		
	}
	if ( "$ethstat" eq "up" && $WIFIFLAG == 1 ) {
		if ( $DEBUG == 1 ) {
			print   "$abbr[$mon] $mday $hour:$min:$sec ","Wifi Off\n$ethstat\n";
		}
		
		system("notify-send \"Wired Network up!\" \"Disabling WIFI card!\"");
		system("nmcli -p con down id avnetwork ");
		system("sudo /sbin/iwconfig wlan0 txpower off");
		sleep(5);
		$ETHFLAG=1;
		$WIFIFLAG=0;
	}
}
#{"id":1,"jsonrpc":"2.0","result":[{"playerid":1,"type":"video"}]}

sub checkxbmc(){
	my $content=get "http://$xbmcoldwebserver/jsonrpc?request={ \"jsonrpc\": \"2.0\", \"method\": \"Player.GetActivePlayers\", \"id\": 1}";
	print "--$content\n";
	if ($content =~ m/video/){print "--true\n";return TRUE;}
	else {print "--true\n";return FALSE;}
}
