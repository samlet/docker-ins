#!/bin/bash
# stubs

if [ $# -lt 1 ]; then	
	echo "assign generator name, use: stubs.sh practice <.suffix>"
	exit -1
fi

work_dir=$HOME/works
opt=$1
total_absents=0
total=0

gen(){
	# programming language constructive elements
	echo "generate $1 in $2"
	cd $2
	for script in basic flows strings converters collections comprehensions \
		pattern_matchings math_ops datetime_ops \
		functions functors objects typeof_ops async net_procs \
		io_procs databases json_procs xml_procs message_procs \
		cli_procs error_procs concurrent_procs ; do
		# echo "create $script"			
		fileName="$script$1"
		touch $fileName
		if [ -s $fileName ]; then 
			# only count file which line count grather than 5 line
			lines=`wc -l $fileName | awk '{print $1}'`
			if [ $lines -gt 5 ]; then
				echo "🐪	$fileName"
			else
				echo "🐨	$fileName"
				((total_absents++))
			fi
		else
			echo "🐌	$fileName"
			((total_absents++))
		fi
		((total++))
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
		gen ".scala" 	"$work_dir/scala/scripts" 

		gen ".ml" 		"$work_dir/ocaml/practice" 
		gen ".hs" 		"$work_dir/haskell/practice" 
		gen ".erl" 		"$work_dir/erlang/practice"
		gen ".exs" 		"$work_dir/erlang/practice_elixir"

		gen ".py" 		"$work_dir/python/practice/v3" 
		gen ".rb" 		"$work_dir/ruby/practice" 
		gen ".sh" 		"$work_dir/shell/practice"		
		gen ".js" 		"$work_dir/node.js/practice/basic"

		gen ".swift" 	"$work_dir/swift/practice"
		gen ".rs" 		"$work_dir/rust/practice"
		gen ".cc" 		"$work_dir/cc/practice"
		gen ".c" 		"$work_dir/c/practice"

		echo ""
		echo "🐨 total absents: $total_absents / $total, 🐌 is absent file."
	;;

    * )
		echo "unknown generator, available generators: practice"
	;;
esac


