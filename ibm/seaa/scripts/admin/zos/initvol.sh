#!/bin/sh
#
# Initialize volume on z/OS endpoint
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
# ./initvol.sh --device=OFOO --volser=FOOVOL
#
# **************************************************************************************************#
# Print usage
printUsage() {
  echo "Usage: $(basename "$0"): " >&2
  echo "  * --devnum=* (short '-dn=*') - devnum is a 3-digit or 4-digit hexadecimal device number used when intializing volume" >&2
  echo "  * --volser=* (short '-v=*') - one-to-six alphanumeric characters long identity of volume being inialized" >&2
}

# Define environment variable for ansible call
# export INITVOL_SCRIPT_DEF="script_name=initvol.sh \
#                     script_args='--devnum={{devnum}} --volser={{volser}}'"

# Parse command line
parseCommandLine() {
    for i in "$@"; do
        case $i in
            --devnum=*|-dn=*)
                devnum=${i#*=}
        ;;
            --volser=*|-v=*)
                volser=${i#*=}
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
  if [ -z "$devnum" ] || [ -z "$volser" ]; then
      echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
      printUsage
      exit 4
  fi

# ******************************************
# Initialize volume on device
# ******************************************
mvscmdauth --pgm=ICKDSF --args='NOREPLYU,FORCE' --sysprint=* --sysin=stdin <<zz
  INIT UNIT(${devnum}) NOVERIFY VOLID(${volser}) VTOC(0,1,14) STGR
zz

# Vary device online
opercmd "v ${devnum},online"

}

# Defaults
devnum=
volser=

# Run script main
main "$@"