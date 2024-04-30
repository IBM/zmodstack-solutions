#!/bin/sh
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# Clean ZPM of z/OS endpoint if not removed completely from OCP undeploy
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
# ./cleanzpm.sh --install_dir="/etc/foo"
# **************************************************************************************************#
printUsage() {
  echo "Usage: $(basename "$0"): " >&2
  echo "  * --install_dir=* (short '-idir=*') - zpm installation directory to be cleaned" >&2
  echo "    --state_dir=* (short '-sdir=*') - zpm state directory to be cleaned, default 'install_dir'" >&2
  echo "    --parent_install_dir=* (short '-pdirs=*') - parent directories of one of more zpm install directories to be cleaned" >&2

}

# Parse command line
parseCommandLine() {
    for i in "$@"; do
        case $i in
            --install_dir=*|-idir=*)
      			  install_dir="${i#*=}"
              # Check last Character
              last_char=$(expr substr "$install_dir" "${#install_dir}" 1)
              if [ "$last_char" = "/" ]; then
                install_dir="${install_dir%?}"
              fi
        ;;
            --state_dir=*|-sdir=*)
                state_dir="${i#*=}"

              # Check last Character
              last_char=$(expr substr "$state_dir" "${#state_dir}" 1)
              if [ "$last_char" = "/" ]; then
                state_dir="${state_dir%?}"
              fi
		    ;;
            --parent_install_dirs=*|-pdirs=*)
              parent_install_dirs="${i#*=}"
              last_char=$(expr substr "$parent_install_dirs" "${#parent_install_dirs}" 1)
              if [ "$last_char" = "/" ]; then
                parent_install_dirs="${parent_install_dirs%?}"
              fi
      			   
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

# Helper functions
clean_installed_products() {
    #set out to input parameters of this function
    out=$*

    # Remove leading and trailing single quotes
    out=$(echo "$out" | sed "s/^'//; s/'$//")

    # Replace newline with space to separate the paths
    out=$(echo "$out" | tr '\n' ' ')

    # Remove leading and trailing whitespace using awk
    out=$(echo "$out" | awk '{$1=$1};1')

    if [ -z "$out" ]; then
      echo "No product installed to be cleaned: $out"
    else
      echo "All product directories to be cleaned: $out"
    fi
    
    set -a # -a Mark variables which are modified or created for export. and view changes to env variables
    while [ -n "$out" ] #while out not empty
    do

      #Get the leading edge directory name
      cleanthis=$(echo "$out" | awk '{print $1}')
      echo "Clean this: $cleanthis"

      # Source zpm product .env file
      zpm uninstall "${cleanthis}"

      #Set the out to remaining directories
      out=$(echo "$out" | awk '{$1=""; print $0}' | awk '{$1=$1};1')

      # Check to see if remaining string contains space
      if expr "$out" : '.* .*' > /dev/null;
       then {
         echo "Continue more directories to clean..."
         # NOP
       } else {
         echo "Clean last directory: ""$out"

         # Source last zpm product .env file
         zpm uninstall "${out}"

         #Set out to empty string
         out=""

         #break out of while loop
         break;
       }
      fi
    done
    set +a
}


# Main function to run script
doclean() {

  # Set install and state directorys to clean
  install_dir="${1}"
  state_dir="${2}"
  echo "Setting environment variables for ZPM installation directory ($install_dir) and state directory($state_dir)"

  #set environment variables for ZPM
  export PATH="$install_dir/package-manager/bin:$PATH"
  export zpm_state_dir="$state_dir"

  # # Try to configure ZPm at install_dir
  # output="$(zpm config set Products_dir "$install_dir" 2>&1)"
  # exit_code="$?"

  # echo "$output"
  # echo "$exit_code"

  # Check the exit code
  if zpm config set Products_dir "$install_dir" 2>&1; then
    echo "ZPM installed in '$install_dir' ..."

    # Iterate and clean up installed zpm products
    clean_installed_products "$(zpm list > ~/zpm.list  && chtag -r ~/zpm.list && cat ~/zpm.list | tail +3 | awk '{installed=$2":"$3; print installed }')"
    
    #Remove ZPM state and installation directories
    # Prompt the user for confirmation
    printf "Are you sure you want to delete state_dir '%s'? [y/N]" "$state_dir"
    while true; do
        read -r response
        case "$response" in
            [Yy])
                echo "Deleting state_dir '$state_dir' ..."
                rm -r "${state_dir:?}"
                break
                ;;
            [Nn]|"")
                echo "Aborting deletion."
                break
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    done

    # Prompt the user for confirmation
    printf "Are you sure you want to delete install_dir '%s'? [y/N]" "$install_dir"
    while true; do
        read -r response
        case "$response" in
            [Yy])
                echo "Deleting install_dir '$install_dir' ..."
                rm -r "${install_dir:?}"
                break
                ;;
            [Nn]|"")
                echo "Aborting deletion."
                break
                ;;
            *)
                echo "Invalid input. Please enter 'y' or 'n'."
                ;;
        esac
    done

    echo "ZPM cleanup for $install_dir and $state_dir complete!"
  else
    echo "ZPM not installed in $install_dir"

  fi
}

# Main function to run script
main() {

  #Parse command line
  parseCommandLine "$@"
  
  # Verify required parameters
	if [ -z "$install_dir" ] && [ -z "$parent_install_dirs" ]; then
	  echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
		printUsage
		exit 4
	fi

  if [ -n "$parent_install_dirs" ]; then {
    echo "List of Parent INSTALL_DIRS to be purged: ${parent_install_dirs}"

    # Iterate over parent directories
    for parent_install_dir in $parent_install_dirs; do
      echo "Parent Directory: $parent_install_dir"

      # Iterate over subdirectories within each parent directory
      for sub_idir in "$parent_install_dir"/*; do
        if [ -d "$sub_idir" ]; then
          printf "\tSubdirectory to be cleaned: $sub_idir"

          # Set install directory
          install_dir="${sub_idir}"

          # Set State directory must be relative to the install dir for this cleanup - install_dir/state
          state_dir="${sub_idir}/state"

          # Clean the directory
          doclean "${install_dir}" "${state_dir}"
        fi
      done
    done
  } else {
    # Check if state directory is not provided and set relative to install dir
    if [ -z "$state_dir" ] && [ -n "$install_dir" ]; then
      state_dir=${install_dir}/state
    fi

    doclean "${install_dir}" "${state_dir}"
  } fi

}

# Defaults
install_dir=
state_dir=
parent_install_dirs=

# Call main
main "$@"
