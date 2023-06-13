#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Usage: $0 directory_name"
  exit 1
fi

# Set variables
DIRECTORY="$1"
COPYRIGHT_STATEMENT_Second_Line_="# Copyright 2023 IBM Inc. All rights reserved"
COPYRIGHT_STATEMENT="#\n"$COPYRIGHT_STATEMENT_Second_Line_"\n# SPDX-License-Identifier: Apache2.0\n#"

# Check for directory
if [ ! -d "$DIRECTORY" ]; then
  echo "Directory $DIRECTORY not found."
  exit 1
fi

# Format variables
# red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;34m"
reset="\033[0m"
yellow="\033[0;33m"

add_to_subdir=true
sticky_dir=
# echo "Are you sure you want to add copyright statement to the files in '$_directory'? [y/N]"
# read -r userInput
    
# Iterate files in directory
find "$DIRECTORY" -type f -print0 | while IFS= read -r -d '' file; do
    # set -x
  if [[ $file != *.md ]]; then
    _directory=$(dirname "$file")
    
    if [[ -z "$sticky_dir" || "$_directory" == "$sticky_dir" || "$add_to_subdir" == "true" ]]; then
        
        # Check if changing directory for adding copyright statements
        if [[ -z "$sticky_dir" || "$_directory" != "$sticky_dir" ]]; then
          echo -e "${cyan}Adding copyrights to files in:${reset} $_directory"
        fi 

        # Set current directory for adding copyright statements for
        sticky_dir=$_directory
        
        # Get first line in file
        # echo "First line: $(head -n 1 "$file")"

        # exit 99
        # Check if first line is bash shebang
        if [ "$(head -n 1 "$file")" == "#!/bin/bash" ]; then

          # Get third line
          thirdline=$(awk 'NR==3' "$file")
          # echo -e "\t Third line: $thirdline"

          # Check if third line has copyright
          if [ "$thirdline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
            echo -e "\t${green}Add copyright to bash script:${reset} $file"
            # Add copyright with first line
            awk -v "copy=$COPYRIGHT_STATEMENT" '{
              if (NR == 1) {
                print $0 "\n" copy "\n";
              } else {
                print $0;
              }
            }' "$file" > temp && mv temp "$file"
          else 
            echo -e "\t${yellow}Skip adding copyright to bash script:${reset} $file"  
          fi

        # Check if first line is sh shebang
        elif [ "$(head -n 1 "$file")" == "#!/bin/sh" ]; then
          # Get third line
          thirdline=$(awk 'NR==3' "$file")
          # echo -e "\t Third line: $thirdline"
          
          # Check if third line has copyright
          if [ "$thirdline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
            echo -e "\t${green}Add copyright to sh script:${reset} $file"
            # Add copyright with first line
            awk -v "copy=$COPYRIGHT_STATEMENT" '{
              if (NR == 1) {
                print $0 "\n" copy "\n";
              } else {
                print $0;
              }
            }' "$file" > temp && mv temp "$file"
          else
            echo -e "\t${yellow}Skip adding copyright to sh script:${reset} $file"
          fi
      # Check if first line already has copyright
      # elif [ "$(head -n 1 "$file")" != "$COPYRIGHT_STATEMENT" ]; then     
      else

        secondline=$(awk 'NR==2' "$file")
        # echo -e "\t Second line: $secondline"
        # Check if third line has copyright
        if [ "$secondline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
          echo -e "\t${green}Add copyright to:${reset} $file"
          # Add copyright statement
          echo -e "$COPYRIGHT_STATEMENT\n" | cat - "$file" > temp && mv temp "$file"
        else
          echo -e "\t${yellow}Skip adding copyright to file:${reset} $file"
        fi
      fi
    else
      echo -e "\t${yellow}Skip adding copyright for:${reset} $_directory"
    #   # exit 1
    fi
  else 
    echo -e "\t${yellow}Skip adding copyright markup file:${reset} $file"
  fi
done

# set +x


# # Iterate files in directory
# find "$DIRECTORY" -type f -print0 | while IFS= read -r -d '' file; do
#   # Get first line in file
#   echo "First line: $(head -n 1 "$file")"

#   # Check if first line is bash shebang
#   if [ "$(head -n 1 "$file")" == "#!/bin/bash" ]; then

#     # Get second line
#     secondline=$(awk 'NR==2' "$file")
#     echo -e "\t Second line: $secondline"

#     # Check if second line has copyright
#     if [ "$secondline" != "$COPYRIGHT_STATEMENT" ]; then
#       # Add copyright with first line
#       awk -v "copy=$COPYRIGHT_STATEMENT" '{
#         if (NR == 1) {
#           print $0 "\n" copy "\n";
#         } else {
#           print $0;
#         }
#       }' "$file" > temp && mv temp "$file"
#     fi

#   # Check if first line is sh shebang
#   elif [ "$(head -n 1 "$file")" == "#!/bin/sh" ]; then
#     # Get second line
#     secondline=$(awk 'NR==2' "$file")
#     echo -e "\t Second line: $secondline"

#     # Check if second line has copyright
#     if [ "$secondline" != "$COPYRIGHT_STATEMENT" ]; then
#       # Add copyright with first line
#       awk -v "copy=$COPYRIGHT_STATEMENT" '{
#         if (NR == 1) {
#           print $0 "\n" copy "\n";
#         } else {
#           print $0;
#         }
#       }' "$file" > temp && mv temp "$file"
#     fi
#   # Check if first line already has copyright
#   elif [ "$(head -n 1 "$file")" != "$COPYRIGHT_STATEMENT" ]; then

#     # Add copyright statement
#     echo -e "$COPYRIGHT_STATEMENT\n" | cat - "$file" > temp && mv temp "$file"
#   fi
# done
