#!/bin/bash

usage() { echo "Usage:"; exit 0; }

UE4_TRUE_SCRIPT_NAME=$(echo \"$0\" | xargs readlink -f)
UE4_PROJECT_ROOT=$(dirname "$UE4_TRUE_SCRIPT_NAME")

echo "Moving to $UE4_PROJECT_ROOT"
cd "$UE4_PROJECT_ROOT"

oldhash=$(md5sum low-light-combat-server-linux.zip)

curl -o low-light-combat-server-linux.zip -z low-light-combat-server-linux.zip storage.blackdrop.se/dl/low-light-combat-server-linux.zip

newhash=$(md5sum low-light-combat-server-linux.zip)

pidfile="llc_server.pid"

if [[ -f $pidfile ]]
then
	pid="$(cat $pidfile)"
else 
	pid=9999999
fi

if [[ "$oldhash" == "$newhash" ]]
then
	echo hash equal, no new server found.
else
	echo "New server downloaded, killing previous server with pid $pid"
	kill -9 $pid

	while kill -0 $pid; do
		echo "Waiting for process to go away"
		sleep 1
	done

	echo "Unpacking the new server"
	unzip -o low-light-combat-server-linux.zip 

fi

if kill -0 $pid
then
	echo "Server already running, will not start up a  new one"
else
	echo "Creating config file"
	mkdir -p ./LinuxServer/LowLightCombat/Saved/Config/LinuxServer
	cp Game.ini ./LinuxServer/LowLightCombat/Saved/Config/LinuxServer/Game.ini
	echo "Starting server"
	chmod +x "$UE4_PROJECT_ROOT/LinuxServer/LowLightCombat/Binaries/Linux/LowLightCombatServer-Linux-Shipping"
	nohup "$UE4_PROJECT_ROOT/LinuxServer/LowLightCombat/Binaries/Linux/LowLightCombatServer-Linux-Shipping" LowLightCombat > log.txt &
	echo $! > $pidfile
	echo "Server started with pid $(cat $pidfile)"
fi
