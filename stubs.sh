#!/bin/bash
# stubs

if [ $# -lt 1 ]; then	
	echo "assign generator name, use: stubs.sh practice <.suffix>"
	exit -1
fi

work_dir=$HOME/works
opt=$1

gen(){
	echo "generate $1 in $2"
	cd $2
	for script in basic flows strings collections comprehensions functions objects async \
		io_procs databases json_procs xml_procs message_procs \
		cli_procs error_procs concurrent_procs ; do
		echo "create $script"			
		touch "$script$1"
	done
}

case "${opt}" in
    "practice" )
		if [ -n "$2" ]; then
			gen $2 $(pwd)
		else
			echo "stubs practice <suffix>" # suffix: .erl
		fi		
    ;;

    "practice.all" )		
		gen "$work_dir/java/practice" ".java"
	;;

    * )
		echo "unknown generator, available generators: practice"
	;;
esac


