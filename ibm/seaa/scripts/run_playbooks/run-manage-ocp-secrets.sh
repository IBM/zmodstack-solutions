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
# ./run-manage-ssh-key
# **************************************************************************************************#
# Print parameter usage
function _printUsage() {
  echo "Usage: $(basename "$0"): "
  echo "    --extra_vars=* (short '-e=*') used to overide ansible variables in seaa framework"
  echo "    --inventory=* (short '-i=*') inventory file to use for playbook run, default (inventory.yaml)"
  echo "    --inventory_loc=* (short '-i_loc=*') directory location of inventory file, default (ansible/playbooks/inventory)"
  echo "    --ansible_verbosity=* (short '-v=*') turn on verbosity for playbook run (0-4), default(0)"
  echo "    --ansible_debug=* (short '-debug=*') turn on low-level debugging, default(false)"
}


function _validateTags {
    # set -x
    IFS=',' read -ra tags <<< "$1"
    tag_type="$2"

    for tag in "${tags[@]}"; do

        # Use to print warning based on type of tag if debug is on
        if [[ "$tag_type" == "tag" ]]; then
            has_tag=true
        elif [[ "$tag_type" == "skip" ]]; then
            has_skiptag=true
        fi
        case $tag in
        #    developer - deploy developer resources
             sshkey)
                continue;
              ;;     
            # "") # Match an empty value NOP
            #     ;;
            *)
                if [[ "$tag_type" == "tag" ]]; then
                    # echo "Unrecognized tag: $tag"
                    echo -e "${red}Unrecognized tag:${reset}: $tag"
                elif [[ "$tag_type" == "skip" ]]; then
                    # echo "Unrecognized skiptag: $tag"
                    echo -e "${red}Unrecognized skiptag:${reset}: $tag"
                
                fi

                # printUsage;
                exit 1;
                ;;
        esac
    done
    # set +x
}

# Parse command line options
function _parseCommandLine() {
    # set -x
    # Don't fail util parse for unknow commands
    export fail_unknown_cmd_or_tags=false 

    # Parse command with included shared util for seaa run playbooks to export SEAA ENV vars 
    parseCommandLine "$@"

    # set +x
    for i in "$@"; do
        case $i in
            --tags=*|-t=*)
                export SEAA_TAGS="${i#*=}"
                _validateTags "$SEAA_TAGS" "tag"
        ;;
            --extra_vars=*|-e=*)
        ;;
            --inventory=*|-i=*)
        ;;
            --inventory_location=*|-i_loc=*)
    	;;
            --ansible_verbosity=*|-v=*)
	    ;;
            --ansible_debug|-adbug)
   	    ;;
            --script_debug|-sdbug)
   	    ;;
            -debug|-dbug)
              continue;
        ;;     
        #     --extra_vars=*|-e=*)
        #         export EXTRAVARS=${i#*=}
        # ;;
        #     --inventory=*|-i=*)
        #         val=${i#*=}
        #         if [[ -n "$val" ]]; then
        #           export INVENTORY=${val} ;
        #         fi
        # ;;
        #     --inventory_location=*|-i_loc=*)
        #         val=${i#*=}
        #         if [[ -n "$val" ]]; then
        #           export SEAA_INVENTORY_LOCATION=${val} ;
        #         fi
		# ;;
        #     --ansible_verbosity=*|-v=*)
		#         export ANSIBLE_VERBOSITY=${i#*=}
	    # ;;
        #     --ansible_debug|-adbug)
   		#         export ANSIBLE_DEBUG=true
        #         echo "Inventory Location: ${INVENTORY_LOCATION}"
        #         echo  "Inventory File: ${INVENTORY}"
        #         echo  "Ansible Tags: ${tags}"
        #         echo  "Ansible Extra-Vars: ${EXTRAVARS}"
	    # ;;
        #     --script_debug|-sdbug)
   		#         echo "Inventory Location: ${INVENTORY_LOCATION}"
        #         echo  "Inventory File: ${INVENTORY}"
        #         echo  "Ansible Tags: ${tags}"
        #         echo  "Ansible Extra-Vars: ${EXTRAVARS}"
        #         set -x
	    # ;;
        #     -debug|-dbug)
   		#         export ANSIBLE_DEBUG=true
        #         echo "Inventory Location: ${INVENTORY_LOCATION}"
        #         echo  "Inventory File: ${INVENTORY}"
        #         echo  "Ansible Tags: ${tags}"
        #         echo  "Ansible Extra-Vars: ${EXTRAVARS}"
        #         set -x
	    # ;;
            --help)
                _printUsage;
                exit 0;
        ;;
            *)
                echo "Unrecognized option: $i"
                _printUsage;
                exit 1;
                ;;
        esac
    done
}


# Main function to run script
function main() {
    # Install require collections
    ansible-galaxy collection install -r "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/collections/requirements.yml"

    # Source usage function and parsing command lines
    # shellcheck source=/dev/null
    source "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks/util/zos_dev_envs_usage.sh"

    #Parse command line
    _parseCommandLine "$@"

    # Set run options for playbook inventory, config extra-vars, overrides, ansible vault parms
    setRunOptions

    # Display tag status
    printTagStatus

    # Display sea environment variable usage info
    printEnvVarUsage

    # # Verify required parameters
	# if [[ -z "$SSH_KEY_DEFINITION" ]]; then
    # 	echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
	# 	printUsage
	# 	exit 4
	# fi

    # Run playbook
    ansible-playbook "${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/playbooks/ocp/manage-ocp-secrets.yml" ${RUNOPTIONS} \
     -e "${SEAA_EXTRA_VARS}" --tags "${SEAA_TAGS}" --skip-tags "${SEAA_SKIPTAGS}" -e "${ev_automation_strategy:=}" 

    # Return Playbook exit code
    return $?

}

# Run script main
main "$@"