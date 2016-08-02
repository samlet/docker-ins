#!/bin/bash
# stubs

if [ $# -lt 1 ]; then	
	echo "assign generator name, use: stubs.sh practice <.suffix>"
	exit -1
fi

work_dir=$HOME/works
opt=$1
total_absents=0

gen(){
	echo "generate $1 in $2"
	cd $2
	for script in basic flows strings collections comprehensions \
		pattern_matchings math_ops \
		functions objects async net_procs \
		io_procs databases json_procs xml_procs message_procs \
		cli_procs error_procs concurrent_procs ; do
		# echo "create $script"			
		fileName="$script$1"
		touch $fileName
		if [ -s $fileName ]; then 
			echo "🐪	$fileName"
		else
			echo "🐌	$fileName"
			((total_absents++))
		fi

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
		gen ".java" 	"$work_dir/java/practice" 
		gen ".ml" 		"$work_dir/ocaml/practice" 
		gen ".hs" 		"$work_dir/haskell/practice" 
		gen ".py" 		"$work_dir/python/practice/v3" 
		gen ".swift" 	"$work_dir/swift/practice"
		gen ".sh" 		"$work_dir/shell/practice"
		gen ".erl" 		"$work_dir/erlang/practice"
		gen ".exs" 		"$work_dir/erlang/practice_elixir"

		echo ""
		echo "🐨 total absents: $total_absents, 🐌 is absent file."
	;;

    * )
		echo "unknown generator, available generators: practice"
	;;
esac


