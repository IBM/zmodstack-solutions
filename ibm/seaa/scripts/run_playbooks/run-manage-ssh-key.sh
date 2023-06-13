#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# **************************************************************************************************#
# Script that calls ansible playbook to manage SSH Key on z/OS Endpoint
# For additional usage information use "--help" flag as input to script.
#
# To run script:
# ./run-undeploy-oel-dev-env_with_roles.sh -t="tags" -e="extra-vars"
#  valid tags:
#    oel-dev
#    zoscb
#    zpm
#    zoau
#    oelcpp
#    python
#    java
#    go
#    nodejs
#
# Example:
# ./run-undeploy-oel-dev-env_with_roles.sh -t="oel-dev" "extra-vars"
# **************************************************************************************************#
# Print parameter usage
function printUsage() {
  echo "Usage: $(basename "$0"): "
  echo "  * --ssh_key_definition=* (short '-sshdef=*') variables that define sshkey being managed)"
  echo "    --extra_vars=* (short '-e=*') used to overide ansible variables in seaa framework"
  echo "    --inventory=* (short '-i=*') inventory file to use for playbook run, default (inventory.yaml)"
  echo "    --inventory_loc=* (short '-i_loc=*') directory location of inventory file, default (ansible/playbooks/inventory)"
  echo "    --ansible_verbosity=* (short '-v=*') turn on verbosity for playbook run (0-4), default(0)"
  echo "    --ansible_debug=* (short '-debug=*') turn on low-level debugging, default(false)"
  echo "    --limit=* (short '-lm=*') limit ansible host/groups to target run against"
}

# Parse command line options
function parseCommandLine() {
    for i in "$@"; do
        case $i in
            --ssh_key_definition=*|-sshdef=*)
                export SSH_KEY_DEFINITION=${i#*=}
        ;;
            --extra_vars=*|-e=*)
                export EXTRAVARS=${i#*=}
        ;;
            --inventory=*|-i=*)
                val=${i#*=}
                if [[ -n "$val" ]]; then
                  export INVENTORY=${val} ;
                fi
        ;;
            --inventory_location=*|-i_loc=*)
                val=${i#*=}
                if [[ -n "$val" ]]; then
                  export SEAA_INVENTORY_LOCATION=${val} ;
                fi
		;;
            --ansible_verbosity=*|-v=*)
		        export ANSIBLE_VERBOSITY=${i#*=}
	    ;;
            --limit=*|-lm=*)
		        export LIMIT=${i#*=}
		;;
            --ansible_debug|-adbug)
   		        export ANSIBLE_DEBUG=true
                echo "Inventory Location: ${INVENTORY_LOCATION}"
                echo  "Inventory File: ${INVENTORY}"
                echo  "Ansible Tags: ${tags}"
                echo  "Ansible Extra-Vars: ${EXTRAVARS}"
	    ;;
            --script_debug|-sdbug)
   		        echo "Inventory Location: ${INVENTORY_LOCATION}"
                echo  "Inventory File: ${INVENTORY}"
                echo  "Ansible Tags: ${tags}"
                echo  "Ansible Extra-Vars: ${EXTRAVARS}"
                set -x
	    ;;
            -debug|-dbug)
   		        export ANSIBLE_DEBUG=true
                echo "Inventory Location: ${INVENTORY_LOCATION}"
                echo  "Inventory File: ${INVENTORY}"
                echo  "Ansible Tags: ${tags}"
                echo  "Ansible Extra-Vars: ${EXTRAVARS}"
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

# Main function to run script
function main() {

    #Set Defaults
    export SSH_KEY_DEFINITION=
    export ANSIBLE_VERBOSITY=0
    export ANSIBLE_DEBUG=false
    export INVENTORY="${TARGET_INVENTORY:-inventory.yaml}"
    export SEAA_INVENTORY_LOCATION=../../ansible/playbooks/inventory
    export LIMIT="${LIMIT}"
    export EXTRAVARS=

    #Parse command line
    parseCommandLine "$@"

    # Verify required parameters
	if [[ -z "$SSH_KEY_DEFINITION" ]]; then
    	echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
		printUsage
		exit 4
	fi

    # Run playbook
    ansible-playbook ../../ansible/playbooks/zos/manage-ssh-key.yml -i "${INVENTORY_LOCATION}"/"${INVENTORY}" \
    -e "${SSH_KEY_DEFINITION}" -e "${EXTRAVARS}" --limit "${LIMIT}" # --flush-cache

    # Return Playbook exit code
    return $?

}

# Run script main
main "$@"
