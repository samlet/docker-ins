#!/bin/bash

declare opt_proc="echo"

showopts () {
  while getopts ":pq:" optname
    do
      case "$optname" in
        "p")
          echo "  - Option $optname is specified"
          opt_proc="proc"
          ;;
        "q")
          echo "  - Option $optname has value $OPTARG"
          ;;
        "?")
          echo "  * Unknown option $OPTARG"
          ;;
        ":")
          echo "  * No argument value for option $OPTARG"
          ;;
        *)
        # Should not occur
          echo "Unknown error while processing options"
          ;;
      esac
    done
  return $OPTIND
}

showargs () {
  for p in "$@"
    do
      echo "  - [$p]"
    done
}

echoargs () {
  for p in "$@"
    do
      echo "  - [$p]"
    done
}

showopts "$@"
argstart=$?
arginfo=$(showargs "${@:$argstart}")    # only for display
echo "Arguments are:"
echo "$arginfo"

# echo "opt_proc is $opt_proc"
case "${opt_proc}" in
    "echo" )
      echo "process ..."
      echoargs "${@:$argstart}"
    ;;

    * )
      echo "doesn't handle ${opt_proc}"
    ;;
esac

# $ process.sh -p -q qoptval abc "def ghi"
# Arguments are:
# [abc]
# [def ghi]
# Options are:
# Option p is specified
# Option q has value qoptval

