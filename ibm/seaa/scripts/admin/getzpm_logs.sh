#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# **************************************************************************************************#
# Script to copy files to host
# Parms:
#  1 - ssh username
#  2 - hostname
#  3 - ssh port
#  4 - source directory to get ZPM logs from
#  5 - target directory to copy ZPM logs to
#
#  Example SFTP script file from local machine
# ./getzpm_logs.sh ibmuser <zos-endpoint> <path-to-log-on-zosendpoint> <path-to-save-logs-on-workstation>
# **************************************************************************************************#

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit
fi


# # Convert Remote log to ascii
#   ssh -p $3 $1@$2 /bin/sh << EOF
  # TODO use remote "scripts/convertzpm_logs.sh" to convert to ascii
# EOF

# Set target directory
target_dir="$5"

# Get name of ZPM log directory
zpm_log_dir_name="$(basename "$4")"

# Clean target directory
rm -r "${target_dir:?}"/"${zpm_log_dir_name}"

#Create target directory to copy logs to.
mkdir -p "${target_dir:?}"/"${zpm_log_dir_name:?}"

# SFTP ZPM log file to local machine directory
sftp -P "$3" "$1@$2:$4" <<EOF
    get -r "$4" "${target_dir}"
    exit
EOF


#Set current work directory
og_pwd="$(pwd)"

# Change directory to local target directory
cd "$target_dir" || exit

# ZIP recursively log file SFTP'ed to target directory
zip -r "$target_dir/${zpm_log_dir_name}".zip ./"${zpm_log_dir_name}"/

#Clean Log files
# rm -r "${target_dir:?}"/"${zpm_log_dir_name}"

# Change working directory back to original working directory
cd "$og_pwd" || exit


