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

sticky_dir=
# echo "Are you sure you want to add copyright statement to the files in '$_directory'? [y/N]"
# read -r userInput
    
# Iterate files in directory
find "$DIRECTORY" -type f -print0 | while IFS= read -r -d '' file; do
    # set -x

  echo "Sticky Directory: $sticky_dir"
  _directory=$(dirname "$file")
  echo "Directory: $_directory"
  
  # if [[ -z "$sticky_dir" || "$_directory" == "$sticky_dir" ]]; then
  #     sticky_dir=$_directory
      
      # Get first line in file
      echo "First line: $(head -n 1 "$file")"

      # exit 99
      # Check if first line is bash shebang
      if [ "$(head -n 1 "$file")" == "#!/bin/bash" ]; then

        # Get third line
        thirdline=$(awk 'NR==3' "$file")
        echo -e "\t Third line: $thirdline"

        # Check if third line has copyright
        if [ "$thirdline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
          echo "Add copyright to bash script $file"
          # Add copyright with first line
          awk -v "copy=$COPYRIGHT_STATEMENT" '{
            if (NR == 1) {
              print $0 "\n" copy "\n";
            } else {
              print $0;
            }
          }' "$file" > temp && mv temp "$file"
        else 
          echo "Skip adding copyright to bash script $file"  
        fi

      # Check if first line is sh shebang
      elif [ "$(head -n 1 "$file")" == "#!/bin/sh" ]; then
        # Get third line
        thirdline=$(awk 'NR==3' "$file")
        echo -e "\t Third line: $thirdline"
        # exit 98
        # Check if third line has copyright
        if [ "$thirdline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
          echo "Add copyright to sh script $file"
          # Add copyright with first line
          awk -v "copy=$COPYRIGHT_STATEMENT" '{
            if (NR == 1) {
              print $0 "\n" copy "\n";
            } else {
              print $0;
            }
          }' "$file" > temp && mv temp "$file"
        else
          echo "Skip adding copyright to sh script $file"
        fi
      # fi
    # Check if first line already has copyright
    # elif [ "$(head -n 1 "$file")" != "$COPYRIGHT_STATEMENT" ]; then     
    else

      secondline=$(awk 'NR==2' "$file")
      echo -e "\t Second line: $secondline"
      # Check if third line has copyright
      if [ "$secondline" != "$COPYRIGHT_STATEMENT_Second_Line_" ]; then
        echo "Add copyright to $file"
        # Add copyright statement
        echo -e "$COPYRIGHT_STATEMENT\n" | cat - "$file" > temp && mv temp "$file"
      else
        echo "Skip adding copyright to file $file"
      fi
    fi
  # else
  #   echo "Skip adding copyright "
  #   # exit 1
  # fi
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
