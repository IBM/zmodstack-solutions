#!/bin/sh
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

#
# Description:
# Hello script
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
# ./greetings.sh --firstname=Jane --lastname=Doe
#
# **************************************************************************************************#
# Print usage
printUsage() {
  echo "Usage: $(basename "$0"): " >&2
  echo "  * --firstname=* (short '-fn=*') - first name of person to greet " >&2
  echo "    --lastname=* (short '-ln=*') - last name of person to greet " >&2
}

# Define environment variable for ansible call coopy this to solutions-enablement/scenarios/scripts/definitions/.env file
# export GREETINGS_SCRIPT_DEF="script_name=greetings.sh \
#  script_args='--firstname={{ firstname }} \
#    --lastname={{ lastname|default('') }}'"

# Parse command line
parseCommandLine() {
    for i in "$@"; do
        case $i in
            --firstname=*|-fn=*)
                firstname=${i#*=}
        ;;
            --lastname=*|-ln=*)
                lastname=${i#*=}
        ;;
            -debug)
                set -x
		;;
            --help)
                printUsage;
                exit 0;
        ;;
            *)
                echo "Unrecognized option: $i"
                printUsage;
                exit 1;
                ;;
        esac
    done
}

# Main function to run script
main() {

  #Parse command line
  parseCommandLine "$@"

  # Verify required parameters
  if [ -z "${firstname}" ]; then
      echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
      printUsage
      exit 4
  fi

  if [ -n "${lastname}" ]; then
    echo "Greetings ${firstname} ${lastname}, nice to meet you!"
  else
    echo "Greetings ${firstname}, sorry I don't know your last name."
  fi

}

# Defaults
firstname=
lastname=

# Run script main
main "$@"
