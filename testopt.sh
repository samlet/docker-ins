#!/bin/bash
echo "OPTIND starts at $OPTIND"
while getopts ":pq:" optname
  do
    case "$optname" in
      "p")
        echo "Option $optname is specified"
        ;;
      "q")
        echo "Option $optname has value $OPTARG"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
    echo "OPTIND is now $OPTIND"
  done

# [ian@pinguino ~]$ ./testopt.sh -p -q
# OPTIND starts at 1
# Option p is specified
# OPTIND is now 2
# No argument value for option q
# OPTIND is now 3

# [ian@pinguino ~]$ ./testopt.sh -p -q -r -s tuv
# OPTIND starts at 1
# Option p is specified
# OPTIND is now 2
# Option q has value -r
# OPTIND is now 4
# Unknown option s
# OPTIND is now 5



