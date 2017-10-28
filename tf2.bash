#!/bin/bash

screenID="tf2-console"

cd $(dirname $0)

function startTF2 {
    ./update-tf2.bash
    screen -S $screenID -d -m tf2/srcds_run -consolelog /var/log/srcds/tf2.log -game tf +sv_pure 1 +map ctf_2fort +maxplayers 32 +ip 130.236.245.45 &
}

function watchForRestart {
tail --retry -F -n 0 /var/log/srcds/tf2.log |\
    while read line; do
	if echo "$line" | grep -E -q 'Your server needs to be restarted in order to receive the latest update.'; then
	    echo $(date) Trying to restart server! >> /var/log/srcds/restart-tf2.log
	    screen -ls | awk -vFS='\t|[.]' '/'$screenID'/ {system("screen -S "$2" -X quit")}'
	    startTF2
	    screen -r $screenID
	fi
    done
}


startTF2
# bash ~/source/chrooms/chrooms/log-watcher.bash &
touch /var/log/srcds/tf2.log
watchForRestart &
screen -r $screenID
echo Exiting tf2.bash
