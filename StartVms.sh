#!/bin/bash

PIDDIR='/var/run/libvirt/qemu'
LOGDIR='/var/log/libvirt'
CONFFILE="$0"
CONFFILE="${CONFFILE##*/}"
SCRNAME="${CONFFILE%.*}"
CONFFILE="${0%/*}/${CONFFILE%.*}.conf"
STARTBOOL="${CONFFILE%/*}/startvms"
LOGFILE="${LOGDIR}/${SCRNAME}.log"
exec &>> "$LOGFILE"

function LogEntry {
	printf "%s:\t%s\n" "$(date +'%Y/%m/%d %H:%M:%S')" "${1}"
}

printf "================================================================================\n"

if [ -e "$STARTBOOL" ]
then
	LogEntry "Okay to start."
else
	LogEntry "'$STARTBOOL' doesn't exist. Aborting."
	printf '\n\n'
	exit 1
fi

if [ -e "$CONFFILE" ]
then
	. "$CONFFILE"
else
	LogEntry "'$CONFFILE' doesn't exist. Fatal error!"
	exit 1
fi

for each in ${VMS[@]}
do
	if [ -e "${PIDDIR}/${each}.pid" ]
	then
		LogEntry "'${each}' appears to be running already. PID = $(cat "${PIDDIR}/${each}.pid")"
	else
		virsh start $each 1>/dev/null
		if [ $? -eq 0 ]
		then
			LogEntry "'${each}' has been started. PID = $(cat "${PIDDIR}/${each}.pid")"
		else
			LogEntry "'${each}' failed to start! :(. Error code = ${?}"
		fi

	fi
done

printf '\n\n'
