#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

#
# Description:
# Clone generated project to new project or find and replace all strings from the generated project
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
#
# Clone new project 'zstack-se-jane' from 'zstack-se-admin-zach' and replace all occurances of 'ibmuser' with 'zpmjane'
#   ./clone_project.sh --namespace=zstack-se-admin-zach --to_namespace=zstack-se-jane --find=ibmuser --replace=zpmjane
#
# Replace all occurrences of '/Users/ibmuser/.ssh/id_zstack' with '/Users/acrand/.ssh/id_jane'
#   ./clone_project.sh --namespace=zstack-se-jane --find='/Users/ibmuser/.ssh/id_zstack' --replace='/Users/ibmuser/.ssh/id_jane'
#
# Replace all occurances of 'ocphost.server.com' with 'ocphost2.server2.com'
#   ./clone_project.sh --namespace=zstack-se-jane --find='ocphost.server.com' --replace='ocphost2.server2.com'
#
# **************************************************************************************************#
# Print usage
function printUsage {
  echo "Usage: $(basename "$0"): " >&2
  echo "  * --namespace=* (short '-n=*') - Namespace of generated project to clone." >&2
  echo "  * --to_namespace=* (short '-tn=*') - Namespace of new project to save changes." >&2
  echo "  * --path=* (short '-p=*') - Directory path to the generated project being cloned, default('') same directory of script.)" >&2
  echo "  * --find=* (short '-f=*') - String to find in generated files." >&2
  echo "  * --replace=* (short '-r=*') - Replace found string with this value." >&2
}

# Format variables
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;34m"
reset="\033[0m"
yellow="\033[1;33m"

# Parse command line
function parseCommandLine {
    for i in "$@"; do
        case $i in
            --namespace=*|-n=*)
                namespace=${i#*=}
        ;;
            --to_namespace=*|-tn=*)
                to_namespace=${i#*=}
        ;;
            --find=*|-f=*)
                find=${i#*=}
        ;;
            --path=*|-p=*)
                path=${i#*=}/
        ;;
            --replace=*|-r=*)
                replace=${i#*=}
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

function cloneProject() {
 # Set base directory to run script
  basedir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

  echo -e "${cyan}Clone '${namespace}' ${reset} ..."

  # Define the original directory and the new directory
  original_dir=$basedir/$path${namespace}
  new_dir=$basedir/$path${to_namespace}

  # Define the string to replace
  original_string=${namespace}
  new_string=${to_namespace}


  if test -d "$new_dir"; then
    echo -e "${red}Directory '$new_dir' already exist!!${reset}"
  else
    # Create a new directory
    mkdir "$new_dir"

    # Loop through all files in the original directory
    while IFS= read -r -d '' file; do
        # Assign the file name to a variable
        filename="$file"

        # Calculate the relative path of the file
        relative_path=$(echo "$filename" | sed "s:$original_dir:$new_dir:")

        # Create the directory structure in the new directory
        mkdir -p "$(dirname "$relative_path")"

        # Copy the file to the new directory
        cp "$filename" "$relative_path"

        # Check if the file starts with "READ"
        if [[ $(basename "$filename") =~ ^READ.* ]]; then
            # Replace original string with new string and pipe to new path
            sed "s/$original_string/$new_string/g" "$filename" > "$relative_path.tmp"

            # Store the desired value of $namespace
            cloned_namespace="** CLONED from '${namespace}' project on $(date +"%Y-%m-%d %T") **\n"

            # Add string to second line of README file
            awk -v cloned="$cloned_namespace" 'NR==1{print $0 "\n\n" cloned} NR!=1{print $0}' "$relative_path.tmp" > "$relative_path"

            rm "$relative_path.tmp"
        else
            # Replace original string with new string and pipe to new path
            sed "s/$original_string/$new_string/g" "$filename" > "$relative_path"
        fi
    done < <(find "$original_dir" -type f -print0)

    echo -e "Cloning of ${cyan}'${namespace}'${reset} -to- ${green}'${to_namespace}'${reset} complete!"
    echo -e "\nSee cloned project: ${green}'${new_dir}'${reset}\n"
  fi

}

# Function to find and replace strings in project, if project is also being cloned strings will be replaced in cloned project
function findAndReplace() {

  # Set base directory to run script
  basedir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

  # Check if adapting to a new project
  if [[ -n "$to_namespace" ]]; then
     # Define the directory of the project to find and replace string
    original_dir=$basedir/$path${to_namespace}
  else
    # Define the directory of the project to find and replace string
    original_dir=$basedir/$path${namespace}
  fi
  # Define the string to replace
  original_string=${find}
  new_string=${replace}

  # flag for checking if changes were made to a file
  changesMade=false

  # Count the number of replacements made
  count=0
  # Loop through all files in the original directory
  while IFS= read -r -d '' file; do
    # Assign the file name to a variable
    filename="$file"

    # Replace the old name with the new name in the file
    awk -v old="$original_string" -v new="$new_string" '{gsub(old, new)}1' "$filename" > temp

    # Check if the substitution was successful
    if ! diff -q "$filename" "temp" >/dev/null 2>&1; then
      echo -e "Substitutions were made in $filename: \n\tchanged ${cyan}'$original_string'${reset} -to- ${green}'$new_string'${reset}\n"

      # Replace original file with temp file
      mv temp "$filename"

      # Set flag for change to file made
      changesMade=true

      # Bump count for changed files
      (( count++ )) || true
    else

      # Delete last temp file
      rm -r temp
    fi
  done < <(find "$original_dir" -type f -print0)

  if [[ "$changesMade" == false ]]; then
    echo -e "${yellow}No files changed for:${reset} '$original_string -to- $new_string', find and replace."
  else
    echo -e "${green}$count files changed with:${reset} '$original_string -to- $new_string' find and replace."
  fi

}

# Main function to run script
function main {

  #Parse command line
  parseCommandLine "$@"

  # Verify required parameters
  if [[ -z "$namespace" ]]; then
      echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
      printUsage
      exit 4
  fi

  # Check if adapting to a new project
  if [[ -n "$to_namespace" ]]; then
    cloneProject "$@"
  fi

  # Check need to find and replace any strings in project
  if [[ -n "$find" && -n "$replace" ]]; then
    findAndReplace "$@"
  fi

}

# Defaults
namespace=''
to_namespace=''
path=''
find=''
replace=''

# Run script main
main "$@"
