#!/bin/bash
# ***********************************
# Pre-Req export Env/Ansible Variable to run Scenario
# ***********************************
# Relative Path to test case directory
relative_path_to_script_dir=../../internal/_acceptance_test

# Set directory to read default variables
export SEAA_CONFIG_PATH_TO_SE_VARIABLES="${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/${relative_path_to_script_dir}/seaa/ga_variables/2023.1.1"

# Set directory for running playbooks
run_playbook_dir="${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks"

# Set base directory to run script
basedir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# Set inventory location
INVENTORY_LOCATION="${basedir}/inventory"

# Set yaml output directory
YAML_OUTPUT_DIR="${basedir}"

# # Set ansible verbosity
verbosity=0

# Set tags used to deploy
tags=zoau
skiptags=

# Run playbook
echo "Admin - Undeploy Admin Project and Broker, ZPM Operators and ZOAU instances from endpoints"
"${run_playbook_dir}/run-undeploy-oel-dev-env.sh" -v="${verbosity}" -t="${tags}" -st="${skiptags}" -i_loc="${INVENTORY_LOCATION}" -e='{
    "seaa_yaml_output_dir": '"${YAML_OUTPUT_DIR}"',
    "seaa_delete_outdir_if_exist": false
  }'
