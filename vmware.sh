#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

# http://jamesreubenknowles.com/vmrun-fusion-2132
# VMware Fusion
if [ -d "/Applications/VMware Fusion.app/Contents/Library" ]; then
    export PATH=$PATH:"/Applications/VMware Fusion.app/Contents/Library"
fi

CMD=$1

ubuntu_file="/Users/xiaofeiwu/Documents/Virtual Machines.localized/Ubuntu 64 位.vmwarevm"
auth="-gu xiaofeiwu -gp xiaofeiwu"

case "$CMD" in
	"ubuntu")		
		vmrun start "$ubuntu_file" nogui
		sleep 1
		vmrun list
		;;
	"ubuntu.stop")
		# 
		vmrun stop "$ubuntu_file" soft
		;;	
	"ubuntu.reboot")
		vmrun reset "$ubuntu_file" soft
		;;

	"list")
		vmrun list
		;;
	"list.procs")
		vmrun $auth listProcessesInGuest "$ubuntu_file"
		;;

	"share")
		
		# 前题: Installing VMware Tools from the Command Line with the Tar Installer
		# https://www.vmware.com/support/ws55/doc/ws_newguest_tools_linux.html#wp1127177

		echo "enable ..."
		vmrun -T fusion enableSharedFolders "$ubuntu_file" runtime
		echo "share ..."
		vmrun -T fusion addSharedFolder "$ubuntu_file" share_folder "$HOME/tmp"
		echo "success, browse the folder ..."
		vmrun $auth listDirectoryInGuest "$ubuntu_file" "/mnt/hgfs/share_folder"
		;;

	"share.browse")
		vmrun $auth listDirectoryInGuest "$ubuntu_file" "/mnt/hgfs/share_folder"
		;;
	"share.remove")
		vmrun -T fusion removeSharedFolder "$ubuntu_file" share_folder 
		;;

	"exec")
		if [ $# -gt 1 ]; then	
			echo "exec script $2 ..."
			vmrun $auth runProgramInGuest "$ubuntu_file" /bin/bash /mnt/hgfs/share_folder/$2
		fi
		;;
	"backup")
		if [ $# -gt 2 ]; then	
			echo "backup ..."
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;
	*)
		echo "no such command: $CMD"
		;;
esac
