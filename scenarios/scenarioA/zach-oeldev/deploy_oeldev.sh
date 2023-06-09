#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# ***********************************
# Pre-Req export Env/Ansible Variable to run Scenario
# ***********************************
# Set directory for running playbooks
run_playbook_dir="${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks"

# Directory containing the script and other script artifacts
scriptdir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# Set inventory location
export SEAA_INVENTORY_LOCATION=${scriptdir}/inventory

# # Set ansible verbosity
verbosity=0

# Set tags used to deploy
tags=oel-dev
skiptags=

# Run playbook
echo "Admin - Deploy Admin Project and Broker, ZPM Operators and ZOAU instances to endpoints"
"${run_playbook_dir}/run-deploy-oel-dev-env.sh" -v="${verbosity}" -t="${tags}" -st="${skiptags}" -e='{
    "seaa_yaml_output_dir": '"${scriptdir}"',
    "seaa_deploy_validate_crs": false
  }'
