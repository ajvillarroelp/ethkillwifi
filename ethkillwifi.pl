#!/usr/bin/perl

#requires sudo /sbin/iwconfig
#<username> ALL=(ALL) NOPASSWD:/sbin/iwconfig

use strict;
########################################################
my $ETHCARD = "enp3s0f2";
my $WLANCARD = "wlp2s0";
my $USBCARD = "enp0s20u";
my $STATPATH = "/sys/class/net";
########################################################

my $WIFIFLAG=0;
my $ETHDOWNWIFIUP=0;
my $NOTIFSUSPFLAG=0;
my $NOTIFIDLEFLAG =0;
my $HomeDir=$ENV{'HOME'};
my $desktopshortcut="$HomeDir/.local/share/applications/ethkillwifi.desktop";

my $SUSPFILE="$HomeDir/.ethkillwifi/ethkillwifi.disable";
my $STATFILE="$HomeDir/.ethkillwifi/ethkillwifi.status";
my $DEBUG=1;

sub setdisableicon;
sub setwifiicon;
sub setethicon;

use sigtrap qw/handler signal_handler normal-signals/;

sub signal_handler {
	setdisableicon;
    exit;

}

sleep(3);

my $wifistat=`cat   /sys/class/net/$WLANCARD/link_mode `;

my $ethstat=`cat  /sys/class/net/$ETHCARD/operstate`;

my @usbfiles;
my $usbstat=0;

for(;;){

	sleep(5);

	 if (-e $SUSPFILE) {
		if ( $DEBUG == 1 ) {
			print "Eth mon disabled...\n";

		}

		if ($NOTIFSUSPFLAG == 0) {
			$NOTIFSUSPFLAG =1;
			setdisableicon;
			system("notify-send \"Eth Mon\" \"Disabled!\"");
		}
		sleep (30);
		next;
	} else {
		$NOTIFSUSPFLAG =0;
	}

	 $ethstat=`cat  /sys/class/net/$ETHCARD/operstate`;
	 chomp($ethstat);

	$wifistat=`cat /sys/class/net/$WLANCARD/link_mode`;
	chomp($wifistat);

	@usbfiles = <$STATPATH/enp?s??u?>; # mobile usb tether
	$usbstat = scalar @usbfiles;

	if ( $DEBUG == 1 ) {
    	print $ETHDOWNWIFIUP,"--",$ethstat,"--",$wifistat,"--",$usbstat," \n";
	}

	#if ( ($ethstat eq "up" && $WIFIFLAG == 0) || ($WIFIFLAG == 1 && $ethstat eq "down" ) ) {
	if ( ( ( $ethstat eq "up" || $usbstat > 0 ) && $wifistat == 0) || ($wifistat == 1 && ( $ethstat eq "down" && $usbstat == 0) ) ) {
		if ( $DEBUG == 1 ) {
			print "Nothing to do...\n";

		}
		if ( $NOTIFIDLEFLAG == 0 ){
			$NOTIFIDLEFLAG = 1;
			if ($ethstat eq "up") {
				setethicon;
			} else {
				setwifiicon;
			}
		}
		next;
	}

	#chomp($ethstat);
	#if ( ("$ethstat" eq "down" && $usbstat == 0 ) && $wifistat == 0 && $ETHDOWNWIFIUP eq 1 ) {
	if ( ("$ethstat" eq "down" && $usbstat == 0 ) ) {

		system("notify-send \"Wired Network down\" \"Enabling WIFI card!\"");
		system("sudo /sbin/iwconfig ".$WLANCARD." txpower on");

		setwifiicon;
		sleep(5);

		$ETHDOWNWIFIUP=0;
		next;

	#}elsif ( ( "$ethstat" eq "up" || $usbstat > 0 ) && $wifistat == 1 && $ETHDOWNWIFIUP eq 0 ) {
	}elsif ( ( "$ethstat" eq "up" || $usbstat > 0 ) ) {

		system("notify-send \"Wired Network up!\" \"Disabling WIFI card!\"");

		system("sudo /sbin/iwconfig ".$WLANCARD." txpower off");

		setethicon;
		sleep(5);
		$ETHDOWNWIFIUP=1;
	}
}

##############################################################
sub setethicon{
	system("sed -i 's/Icon=ethkilloff/Icon=ethprimary/' $desktopshortcut");
	system("sed -i 's/Icon=wifiprimary/Icon=ethprimary/' $desktopshortcut;touch $desktopshortcut");
	system("echo ethernet > $STATFILE");
}

sub setwifiicon{
	system("sed -i 's/Icon=ethkilloff/Icon=wifiprimary/' $desktopshortcut");
	system("sed -i 's/Icon=ethprimary/Icon=wifiprimary/' $desktopshortcut;touch $desktopshortcut");
	system("echo wifi > $STATFILE");
}

sub setdisableicon{
	system("sed -i 's/Icon=wifiprimary/Icon=ethkilloff/' $desktopshortcut");
	system("sed -i 's/Icon=ethprimary/Icon=ethkilloff/' $desktopshortcut;touch $desktopshortcut");
}
