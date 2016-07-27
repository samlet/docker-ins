#!/bin/bash
# stubs

if [ $# -lt 1 ]; then	
	echo "assign generator name, use: stubs.sh practice <.suffix>"
	exit -1
fi

opt=$1

case "${opt}" in
    "practice" )
		if [ -n "$2" ]; then
			for script in basic flows strings collections functions objects async \
				io_procs databases json_procs xml_procs message_procs \
				cli_procs error_procs concurrent_procs ; do
				echo "create $script"			
				touch "$script$2"
			done
		else
			echo "stubs practice <suffix>" # suffix: .erl
		fi		
    ;;

    * )
		echo "unknown generator, available generators: practice"
	;;
esac


