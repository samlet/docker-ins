
declare opt_proc="echo"
declare preset="none"

showopts () {
  # to add a option, add a shortcut character at first
  while getopts ":piq:" optname   # shortcut characters
    do
      case "$optname" in
        "p")
          echo "  - Option $optname is specified"
          opt_proc="proc"
          ;;
        "i")
          echo "  - Option $optname is specified"
          opt_proc="install"
          ;;
        "q")
          echo "  - Option $optname has value $OPTARG"
          preset=$OPTARG
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

