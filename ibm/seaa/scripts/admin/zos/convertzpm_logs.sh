#!/bin/sh
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# **************************************************************************************************#
# Script to convert directory of files to ascii or ebcdic
# Parms:
#  1 - direcotry of files to convert
#  2 - convert to ascii or ebcdic
# Example;
# ./scripts/convertzpm_logs.sh <path-to-log-on-zosendpoint> ascii
#
# ./scripts/convertzpm_logs.sh /etc/zstack/state/package-manager-state/logs/zpm_2023_05_23_08_30_52_66113 ascii
# Check after convert
# cat /etc/zstack/state/package-manager-state/logs/zpm_2023_05_23_08_30_52_66113/log_IBMUSER_.0
# ls -laT /etc/zstack/state/package-manager-state/logs/zpm_2023_05_23_08_30_52_66113
# **************************************************************************************************#

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
fi

#Convert any IBM-1047 files to ascii
convertoascii() {
  file="$1"
  out=$(ls -lT "$file")

  # while IFS= read -r line; do

    filetype=$(echo "$out" | awk '{print $2}')

    # Process each file type here
    echo "File type: $filetype"
  
    if [ "$filetype" = "IBM-1047" ] ; then
      echo "convert $f from ebcdic to ascii"

      # Remove Read Only
      /bin/chtag -r "$f"
      
      tmp_file="$$.tmp"  # Create a unique temporary file name
      
      # Convert from ebcdic to ISO8859-1
      /bin/iconv -f "$filetype" -t ISO8859-1 "$f" > "$tmp_file"

      # Replac file with tmpfile
      mv $tmp_file "$f"
      
      # Changtag to ISO8859-1 
      /bin/chtag -t -c ISO8859-1  "$f"

      return
    fi
#   done << EOF
#   $out
# EOF

}

#Convert any IBM-1047 files to ascii
convertoebcdic() {
  file="$1"
  out=$(ls -lT "$file")

  # while IFS= read -r line; do

    filetype=$(echo "$out" | awk '{print $2}')

    # Process each file type here
    echo "File type: $filetype"
  
    if [ "$filetype" != "IBM-1047" ] ; then
      echo "convert $f to ebcdic"

      # Remove Read Only
      /bin/chtag -r "$f"

      tmp_file="$$.tmp"  # Create a unique temporary file name
      
      # COnvert to ebcdic
      /bin/iconv -f "$filetype" -t IBM-1047 "$f" > "$tmp_file"
      
      # Replace file with tmp file
      mv $tmp_file "$f"

      # Changtag to ebcdic
      /bin/chtag -t -c IBM-1047 "$f"
            
      return
    fi
#   done << EOF
#   $out
# EOF

}

# Iterate over files in directory passed in
 for f in "$1"/*;
  do
    if [ -w "$f" ]; then
      if [ "$2" = "ascii" ]; then
        convertoascii "$f"
      elif [ "$2" = "ebcdic" ]; then
        convertoebcdic "$f"
      fi
    fi

  done

