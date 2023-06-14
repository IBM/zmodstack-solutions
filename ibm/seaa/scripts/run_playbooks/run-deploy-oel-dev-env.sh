#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# **************************************************************************************************#
# Script that calls ansible playbook to Deploy zCM Stack configuration to z/OS Endpoint to create
# development environment on USS
#
# For additional usage information use "--help" flag as input to script.
#
# To run script:
# ./run-undeploy-oel-dev-env_with_roles.sh -t=tags -e=SEAA_EXTRA_VARS
#  valid tags:
#    oel-dev - deploy all compilers, languages and tools
#    zoscb   - deploy Zos Cloud Broker
#    zpm     - deploy ZosPackage Manager
#    go      - deploy Go
#    java    - deploy Java
#    nodejs  - deploy NodeJS
#    oelcpp - deploy OelCPP
#    python  - deploy Python
#    zoau    - deploy ZOAU
#
# Example:
# ./run-deploy-oel-dev-env.sh -t=oel-dev -e="extra-vars"
# **************************************************************************************************#
# Main function
function main() {
    # Install require collections
    ansible-galaxy collection install -r "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/collections/requirements.yml"

    # Source usage function and parsing command lines
    # shellcheck source=/dev/null
    source "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks/util/zos_dev_envs_usage.sh"

    #Parse command line
    parseCommandLine "$@"

    # Set run options for playbook inventory, config extra-vars, overrides, ansible vault parms
    setRunOptions

    # Display tag status
    printTagStatus

    # Display sea environment variable usage info
    printEnvVarUsage

    #Run playbook
    ansible-playbook "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/playbooks/zos_dev_envs/oel/deploy-oel-dev-env.yml" ${RUNOPTIONS} \
     -e "${SEAA_EXTRA_VARS}" --tags "${SEAA_TAGS}" --skip-tags "${SEAA_SKIPTAGS}" -e "${ev_automation_strategy:=}"

    # Return Playbook exit code
    return $?
}

# Set defaults
export SEAA_TAGS=
export SEAA_SKIPTAGS=
export SEAA_EXTRA_VARS=
export SEAA_INVENTORY="${SEAA_INVENTORY:-inventory.yaml}"
export SEAA_INVENTORY_LOCATION="${SEAA_INVENTORY_LOCATION:-${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/playbooks/inventory}"

# Variables to debug automation run
export ANSIBLE_VERBOSITY=0
export ANSIBLE_DEBUG=false


# Run script main
main "$@"
