#!/bin/bash
# Directory to run playbook
run_playbook_dir="${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks"

# Directory containing the script and other script artifacts
script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# Export directory inventory location
export SEAA_INVENTORY_LOCATION="$script_dir/inventory"
export SEAA_INVENTORY=sample-inventory.yaml

verbosity=0

# run SEAA script
"${run_playbook_dir}/run-deploy-oel-dev-env.sh" -v="${verbosity}" -t="${tags}" -st="${skiptags}" -e="@$extravars_file"
