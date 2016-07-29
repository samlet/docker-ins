#!/bin/bash

showopts () {
  while getopts ":pq:" optname
    do
      case "$optname" in
        "p")
          echo "  - Option $optname is specified"
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

processargs () {
  for p in "$@"
    do
      echo "  - [$p]"
    done
}

optinfo=$(showopts "$@")
argstart=$?
arginfo=$(showargs "${@:$argstart}")
echo "Arguments are:"
echo "$arginfo"
echo "Options are:"
echo "$optinfo"

echo "create compose ..."
processargs "${@:$argstart}"

# $ compose.sh -p -q qoptval abc "def ghi"
# Arguments are:
# [abc]
# [def ghi]
# Options are:
# Option p is specified
# Option q has value qoptval

