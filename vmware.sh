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
	"start")		
		vmrun start "$ubuntu_file" nogui
		sleep 1
		vmrun list
		;;
	"stop")
		# 
		vmrun stop "$ubuntu_file" soft
		;;	
	"reboot")
		vmrun reset "$ubuntu_file" soft
		;;

	"list")
		vmrun list
		;;
	"list.procs")
		vmrun $auth listProcessesInGuest "$ubuntu_file"
		;;

	"ssh")
		ssh dev
		;;

	"share.init")
		# only execute once

		# 前题: Installing VMware Tools from the Command Line with the Tar Installer
		# https://www.vmware.com/support/ws55/doc/ws_newguest_tools_linux.html#wp1127177

		echo "enable ..."
		# vmrun -T fusion enableSharedFolders "$ubuntu_file" runtime
		vmrun -T fusion enableSharedFolders "$ubuntu_file" 
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

	"mount.list")
		vmrun $auth listDirectoryInGuest "$ubuntu_file" "/mnt/hgfs/"
		;;
	"mount")
		# example: vmware.sh mount async $(pwd)
		if [ $# -gt 2 ]; then	
			echo "mount $2 to $3 ..."
			vmrun -T fusion addSharedFolder "$ubuntu_file" $2 "$3"
		fi
		;;
	"umount")
		if [ $# -gt 1 ]; then	
			echo "umount $2 to $3 ..."
			vmrun -T fusion removeSharedFolder "$ubuntu_file" $2 
		fi
		;;
	"exec")
		if [ $# -gt 1 ]; then	
			echo "exec script $2 ..."
			vmrun $auth runProgramInGuest "$ubuntu_file" /bin/bash /mnt/hgfs/share_folder/$2
		fi
		;;
	"+local")
		TARGET=/works/cc/linux.ubuntu.1604
		SOURCE_ROOT=dev:/usr/local
		rsync -avz --progress --delete $SOURCE_ROOT $TARGET
		;;
	"backup")
		if [ $# -gt 2 ]; then	
			echo "backup ..."
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;


	"docker.create")
		# vmware docker.create hadoop 8192
		if [ $# -gt 1 ]; then	
			vmname=$2
			memory_size=4096
			if [ $# -gt 2 ]; then	
				memory_size=$3
			fi
			echo "create docker vm $vmname ..."
			docker-machine create --engine-registry-mirror=https://y5q5tgic.mirror.aliyuncs.com --vmwarefusion-disk-size=40000 --vmwarefusion-memory-size=$memory_size -d vmwarefusion $vmname
		else
			echo "usage: vmware.sh docker.create <vm-name>"
			echo "example: vmware.sh docker.create hadoop 8192"
		fi
		;;

	*)
		echo "no such command: $CMD"
		echo "available commands: start, stop, reboot, list, list.procs, mount.list, mount, umount, exec, +local, share.browse"
		;;
esac
