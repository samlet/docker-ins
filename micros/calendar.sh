#!/bin/bash

declare opt_proc="echo"

showopts () {
  while getopts ":pgq:" optname
    do
      case "$optname" in
        "p")
          echo "  - Option $optname is specified"
          opt_proc="proc"
          ;;
        "q")
          echo "  - Option $optname has value $OPTARG"
          ;;
        "g")
          opt_proc="generate"
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

    "generate")
      # https://github.com/infinet/lunar-calendar

      # [fail]
      # name=t.cal enter.sh python:2.7
      # pip install numexpr numpy
      # ./lunar_ical.py 2016 > __chinese_lunar_2016.ics

      # or enter folder "c", make
      echo "execute ./lunarcal 2016 > chinese_lunar_2016.ics"
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

