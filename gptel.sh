#!/usr/bin/expect

set username "root"
set password "alpine"
set rsyncPort 10873
set logsPath   "/Library/Logs/CrashReporter/Baseband/"
set devicePath "rsync://root@localhost:$rsyncPort/root"
set bbUpdatePath "rsync://root@localhost:$rsyncPort/root/tmp"
set switchVar [lindex $argv 0]

#switchVar =1 is for putting files onto phone, just one argment puts it into /tmp directory, 2 args puts it wherever you want after /root/
#switchVar =2 is for retrieeving drivetest CSI logs off phone, 2nd arg is for date, 3rd is for local directory


if { $argc == 2} {
	set localPath [lindex $argv 1]
	
} elseif { $argc == 3 && $switchVar == 1 } {
	set localPath [lindex $argv 1]
	set remotePath [lindex $argv 2]
 	
} elseif { $argc == 3 && $switchVar == 2 } {
	set dateDir [lindex $argv 1]
	set localPath [lindex $argv 2]
 	}

	

#rsync -av --progress rsync://root@localhost:10873/root/var/root/DriveTest-Dec05 .

#puts "\nTest"
puts "$switchVar"
#puts "\nWe're testing out variables, localpath is $localPath, remotepath is $remotePath" 

if { $switchVar == 1  &&  $argc == 2 } {
	spawn rsync -av --progress $localPath/ $bbUpdatePath
	puts "File should have been sent correctly from $localPath/ to /root/tmp"
expect {	
	timeout {	send_user "\n Cannot log into the Device..."
				send_user "  Please check whether the device is connected.\n\n"
				exit 1
	}
	"Password:" { send "$password\r" }
	"building" 	{ send_user " Getting File List. Done.\n"}
}
send "\r"
expect "$"

} elseif { $switchVar == 2 && $argc == 3 } {
	puts "trying to connect now"
	spawn rsync -av --progress $devicePath/var/root/DriveTest-$dateDir $localPath
	puts "logs have been pulled from $devicePath/root/var/DriveTest-$dateDir/ to $localPath"
expect {	
	timeout {	send_user "\n Cannot log into the Device..."
				send_user "  Please check whether the device is connected.\n\n"
				exit 1
	}
	"Password:" { send "$password\r" }
}
send "\r"
expect "$"

} elseif { $switchVar == 2 } {
	puts "trying to connect now"
	spawn rsync -av --progress $devicePath/var/logs/CrashReporter/Baseband/ $localPath
	puts "logs have been pulled from $devicePath/root/var/logs/CrashReporter/Baseband to $localPath"
expect {	
	timeout {	send_user "\n Cannot log into the Device..."
				send_user "  Please check whether the device is connected.\n\n"
				exit 1
	}
	"Password:" { send "$password\r" }
}
send "\r"
expect "$"


#Else put files in certain folder
} elseif { $argc == 3 } {
	spawn rsync -av --progress $localPath/ $devicePath$remotePath
expect {	
	timeout {	send_user "\n Cannot log into the Device..."
				send_user "  Please check whether the device is connected.\n\n"
				exit 1
	}
	"Password:" { send "$password\r" }
	"building" 	{ send_user " Getting File List. Done.\n"}
}
send "\r"
expect "$"

}



spawn telnet localhost 10023
expect {
    timeout {	send_user "\n Cannot log into the Device..."
		send_user " Please check whether the device is connected.\n\n"
		exit 1
            }
	"login:" {send "$username\r"}
	}
expect "assword:"
send "$password\r"
expect "~"
if { $switchVar == 1 } {
	send "launchctl unload /System/Library/LaunchDaemons/com.apple.CommCenter.plist\r"
	send "BBUpdaterExtreme update -P -e /tmp/IC\\t"
	interact
#expect "~"
	}
send "alias lm='ls -FlrthG'\r"
send "alias ctm='CoreTelephonyMonitor'\r"
send "alias vml='cd /var/mobile/Library/;lm'\r "
send "alias jtag='killall -USR1 CommCenter'\r"
send "alias kcc='killall -USR2 CommCenter'\r"
send "alias jtagc='killall -USR1 CommCenterClassic'\r"
send "alias uc='launchctl unload /System/Library/LaunchDaemons/com.apple.CommCenter.plist'\r"
send "alias lc='launchctl load /System/Library/LaunchDaemons/com.apple.CommCenter.plist'\r"
send "alias vwl='cd /var/wireless/Library/Logs/CrashReporter/Baseband/'\r"
send "alias vwp='cd /var/wireless/Library/Preferences'\r"
send "alias eping='ETLTool USB ping'\r"
send "alias tlatest='tail -F /var/wireless/Library/Logs/latest-global-log.txt'\r"
send "alias lbb='BBUpdaterSupreme uf -z Trek*.zip -w -a'\r"
send "alias plcb='plutil -convert xml1 /var/mobile/Library/Carrier\ Bundle.bundle/carrier.plist'\r"
send "alias vimcb='vim /var/mobile/Library/Carrier\ Bundle.bundle/carrier.plist'\r"
send "clear \r"

#ln -s /var/logs/CrashReporter/Baseband/ ~/bb/
interact

##RSYNC_PASSWORD=alpine /usr/bin/rsync -av --progress rsync://root@localhost:10873/root/Library/Logs/CrashReporter/Baseband/log_bb* ~/Dummy/

