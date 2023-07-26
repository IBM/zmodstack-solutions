#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# **************************************************************************************************#
# Script that calls ansible playbook to Undeploy zCM Stack configuration to z/OS Endpoint
# to remove development environment on OCP and USS
#
# For additional usage information use "--help" flag as input to script.
#
# To run script:
# ./run-undeploy-oel-dev-env_with_roles.sh -t="tags" -e="extra-vars"
#  valid tags:
#    oel-dev - undeploy all compilers, languages and tools
#    zoscb   - undeploy Zos Cloud Broker
#    zpm     - undeploy ZosPackage Manager
#    go      - undeploy Go
#    java    - undeploy Java
#    nodejs  - undeploy NodeJS
#    oelcpp - undeploy OelCPP
#    python  - undeploy Python
#    zoau    - undeploy ZOAU
#
# Example:
# ./run-undeploy-oel-dev-env.sh -t="oel-dev" -e="extra-vars"
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
    ansible-playbook "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/playbooks/zos_dev_envs/oel/undeploy-oel-dev-env.yml" ${RUNOPTIONS} \
     -e "${SEAA_EXTRA_VARS}" -e "${ev_automation_strategy:=}"

    # Return Playbook exit code
    return $?
}

# Run script main
main "$@"
