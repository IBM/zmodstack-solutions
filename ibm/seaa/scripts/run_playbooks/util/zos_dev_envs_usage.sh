#!/bin/bash
#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# Exit script on error
set -e

# Format variables
red="\033[0;31m"
green="\033[0;32m"
cyan="\033[0;34m"
reset="\033[0m"
yellow="\033[0;33m"

# Default extra-vars file used if exist and no extra vars are passed to script
export SEAA_DEFAULT_EXTRAVARS="${SEAA_CONFIG_PATH_TO_SE_VARIABLES:-${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/variables}/seaa-extra-vars.json"

echo $SEAA_DEFAULT_EXTRAVARS
# exit 99
# Print usage
function printUsage {
  echo "Usage: $(basename "$0"): "
  echo "    --tags=* (short '-t=*') tag of I component(s) to deploy/undeploy ('oel-dev' - all components, or specify component(s))"
  echo "    --extra_vars=* (short '-e=*') used to overide ansible variables in seaa framework, can be a JSON structure or @FILE reference"
  echo "    --override_values=* (short '-ov=*') list of values to override in the provided Ansible SEAA_EXTRA_VARS JSON @FILE reference"
  echo "    --inventory=* (short '-i=*') inventory file to use for playbook run, default (inventory.yaml)"
  echo "    --inventory_loc=* (short '-i_loc=*') directory location of inventory file, default (ansible/playbooks/inventory)"
  echo "    --ansible_verbosity=* (short '-v=*') turn on verbosity for playbook run (0-4), default(0)"
  echo "    --ansible_debug (short '-adbug') turn on low-level debugging, default(false)"
  echo "    --script_debug (short '-sdbug') turn on low-level debugging, default(false)"
  echo "    --skip-tags=* (short '-st=*') limit ansible host/groups to target run against"
#   echo "    --limit=* (short '-lm=*') limit ansible host/groups to target run against"
}

function printEnvVarUsage {
    echo -e "Display SEAA environment variables ***********************************************************"

    # Check to see if SEAA_AUTOMATION_STRATEGY ENV provided
    if [[ -n "${SEAA_CONFIG_PATH_TO_SE_VARIABLES+1}" ]]; then
        echo -e "\t${green}Using environment variable${reset} '${cyan}SEAA_CONFIG_PATH_TO_SE_VARIABLES${reset}': $SEAA_CONFIG_PATH_TO_SE_VARIABLES"

    fi

    # Check to see if SEAA_AUTOMATION_STRATEGY ENV provided
    if [[ -n "${SEAA_AUTOMATION_STRATEGY+1}" ]]; then
        echo -e "\t${green}Using environment variable${reset} '${cyan}SEAA_AUTOMATION_STRATEGY${reset}': $SEAA_AUTOMATION_STRATEGY"

    fi

    # Check to see if SEAA_INVENTORY_LOCATION ENV provided
    if [[ -n "${SEAA_INVENTORY_LOCATION+1}" ]]; then
        echo -e "\t${green}Using environment variable${reset} '${cyan}SEAA_INVENTORY_LOCATION${reset}': $SEAA_INVENTORY_LOCATION"

    fi

    # Check to see if SEAA_INVENTORY ENV provided
    if [[ -n "${SEAA_INVENTORY+1}" ]]; then
        echo -e "\t${green}Using Environment variable${reset} '${cyan}SEAA_INVENTORY${reset}': $SEAA_INVENTORY"

    fi

    if [[ -n "${SEAA_ANSIBLE_VAULT_PASSWORD_FILE+1}" ]]; then
        echo -e "\t${green}Using Environment variable${reset} '${cyan}SEAA_ANSIBLE_VAULT_PASSWORD_FILE${reset}': $SEAA_ANSIBLE_VAULT_PASSWORD_FILE"

    fi
   
    echo -e "\n  EXPORTED SEAA environment variables ***********************************************************"

    # Check to see if SEAA_CONFIG_EXTRAVARS_FILE ENV provided
    if [[ -n "${SEAA_EXTRA_VARS+1}" ]]; then
        echo -e "\t${green}Environment variable${reset} '${cyan}SEAA_EXTRA_VARS${reset}': $SEAA_MASKED_EXTRAVARS"

    fi


    if [[ -n "${SEAA_TAGS+1}" ]]; then
        echo -e "\t${green}Environment variable${reset} '${cyan}SEAA_TAGS${reset}': $SEAA_TAGS"

    fi

    if [[ -n "${SEAA_SKIPTAGS+1}" ]]; then
        echo -e "\t${green}Environment variable${reset} '${cyan}SEAA_SKIPTAGS${reset}': $SEAA_SKIPTAGS"

    fi
}
# Flags for tags
has_tag=false
has_skiptag=false

# Flag to test if EXTRA
isExtraVarsFileReference=false

# JSON String of values to override in JSON File
overrideValues=

function validateTags {
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
             developer)
                continue;
              ;;     
        #    oel-dev - deploy all compilers, languages and tools
             oel-dev)
                continue;
              ;;               
        #    zoscb   - deploy Zos Cloud Broker
             zoscb)
                continue;
              ;;               
        #    zpm     - deploy ZosPackage Manager
             zpm)
                continue;
              ;;               
        #    go      - deploy Go
             go)
                continue;
              ;;               
        #    java    - deploy Java
             java)
                continue;
              ;;               
        #    nodejs  - deploy NodeJS
             nodejs)
                continue;
              ;;               
        #    oelcpp - deploy OelCPP
             oelcpp)
                continue;
              ;;               
        #    python  - deploy Python
             python)
                continue;
              ;;               
        #    zoau    - deploy ZOAU
             zoau)
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
function parseCommandLine {
    for i in "$@"; do
        case $i in
            --tags=*|-t=*)
                export SEAA_TAGS="${i#*=}"
                validateTags "$SEAA_TAGS" "tag"
        ;;
            --extra_vars=*|-e=*)
                val="${i#*=}"

                if [[ "${val}" == "@"* ]] && [[ ${#val} -eq 1 ]]; then
                    isExtraVarsFileReference=true
                    continue;
                elif [[ "${val}" == "@"* ]]; then
                    isExtraVarsFileReference=true
                fi
                export SEAA_EXTRA_VARS="${val}" # ${i#*=}
        ;;
            --override_values=*|-ov=*)
                overrideValues="${i#*=}"
        ;;
            --inventory=*|-i=*)
                val="${i#*=}"
                if [[ -n "$val" ]]; then
                  export SEAA_INVENTORY="${val}" ;
                fi
        ;;
            --inventory_location=*|-i_loc=*)
                val="${i#*=}"
                if [[ -n "$val" ]]; then
                  export SEAA_INVENTORY_LOCATION="${val}" ;
                fi
		;;
            --ansible_verbosity=*|-v=*)
		        export ANSIBLE_VERBOSITY="${i#*=}"
	    ;;
            --skip-tags=*|-st=*)
		        export SEAA_SKIPTAGS="${i#*=}"
                validateTags "$SEAA_SKIPTAGS" "skip"
		;;
        #     --limit=*|-lm=*)
		#         export LIMIT=${i#*=}
		# ;;
        #     --limit_ocp=*|-lmo=*)
		#         export LIMIT_OCP="${i#*=}"
		# ;;
        #     --limit_zos=*|-lmz=*)
		#         export LIMIT_ZOS="${i#*=}"
		# ;;
            --ansible_debug|-adbug)
   		        export ANSIBLE_DEBUG=true
                echo "Inventory Location: ${SEAA_INVENTORY_LOCATION}"
                echo  "Inventory File: ${SEAA_INVENTORY}"
                # echo  "Ansible Tags: ${SEAA_TAGS}"
                # echo  "Ansible Extra-Vars: ${SEAA_EXTRA_VARS}"
                # echo  "OCP Limit: ${LIMIT_OCP}"
	    ;;
            --script_debug|-sdbug)
   		        echo "Inventory Location: ${SEAA_INVENTORY_LOCATION}"
                echo  "Inventory File: ${SEAA_INVENTORY}"
                # echo  "Ansible Tags: ${SEAA_TAGS}"
                # echo  "Ansible Extra-Vars: ${SEAA_EXTRA_VARS}"
                # echo  "OCP Limit: ${LIMIT_OCP}"
                set -x
	    ;;
            -debug|-dbug)
   		        export ANSIBLE_DEBUG=true
                echo "Inventory Location: ${SEAA_INVENTORY_LOCATION}"
                echo  "Inventory File: ${SEAA_INVENTORY}"
                echo  "Ansible Tags: ${SEAA_TAGS}"
                echo  "Ansible Extra-Vars: ${SEAA_EXTRA_VARS}"
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

function overrideAndMaskExtraVars {
  # echo $overrideValues

  # Check if input file with ExtraVARS is provided
  if [[ -n "${1}" && -n "$overrideValues" ]]; then
    # Set input file and trimmed '@' char from front
    input_file=${1:1}

    # Use Stream editor to pre-process and remove and comments in JSON file
    new_input=$(sed 's/\/\*.*\*\///' "$input_file"| jq '.' )
 
    if [ "$ANSIBLE_VERBOSITY" -gt 0 ]; then
        # Print message for processing extra-vars file
        echo -e "${green}Override extra-vars file:${reset} '${input_file}' ...\n\t With: '$overrideValues' "    
    fi 
    
    # Set output JSON file by adding and overriding from overrideValues JSON
    output_file=$(jq -nc --argjson original "$new_input" \
        --argjson values "$overrideValues" \
        '
        reduce ($values | to_entries[]) as $pair ($original;
            if has($pair.key) then .[$pair.key] = $pair.value else . end
        )
        | del(.[] | select(. == "" or . == []) )

        # Check if fields in $values exist in $original, if not add them to output
        | reduce ($values | keys_unsorted[]) as $key (.;
            if ($original | has($key)) then . else . + {($key): $values[$key]} end
        )
        ' <(echo "$new_input"))

    # Export the SEAA_EXTRA_VARS variable
    export SEAA_EXTRA_VARS="$output_file"
  # Check if extra-vars is a file reference  
  elif [[ "$isExtraVarsFileReference" == "true" ]]; then

    # Set input file and trimmed '@' char from front
    input_file="${SEAA_EXTRA_VARS:1}"

    # Check if file contains comment characters
    if grep -q '\/\*' "$input_file" && grep -q '\*\/' "$input_file" || grep -q '\/\/' "$input_file"; then
      # Export the SEAA_EXTRA_VARS variable
      SEAA_EXTRA_VARS=$(sed 's/\/\*.*\*\///' "$input_file"| jq '.' )
    #   SEAA_EXTRA_VARS==$(sed -e 's/\/\*[^*]*\*\///g' "$input_file" | jq '.')
    #   SEAA_EXTRA_VARS=$(sed -e 's|\/\/[^/].*$||' -e 's/\/\*[^*]*\*\///g' "$input_file" | jq '.')


    else # No Pre-processing of JSON file required for comment characters

      # Create the SEAA_EXTRA_VARS variable
      SEAA_EXTRA_VARS=$(jq '.' "$input_file")

    fi

  fi

  # Check if SEAA_EXTRA_VARS env variable is provided
  if [[ -n "${SEAA_EXTRA_VARS}" ]]; then
    # Print extravars to Terminal
    if [[ -n "$input_file" ]]; then
      echo
      echo -e "${green}Using extra-vars file:${reset} '$input_file'"
    else
      echo #Print empty line
    fi
    if [ "$ANSIBLE_VERBOSITY" -gt 0 ]; then
    # if [[ "$ANSIBLE_DEBUG" == "true" ]]; then
        echo -e "${green}Merged extra-vars for playbook run:${reset} "
        echo "$SEAA_EXTRA_VARS" | jq 'walk(
            if type == "object" then
                with_entries(
                    if .key | test("(?i)password|token") then
                        .value |= "***MASKED***"
                    else
                        .
                    end
                )
            else
                .
            end
        )'
    fi
    # Export Masked extra vars env variable
    SEAA_MASKED_EXTRAVARS=$(echo "$SEAA_EXTRA_VARS" | jq 'walk(
          if type == "object" then
              with_entries(
                  if .key | test("(?i)password|token") then
                      .value |= "***MASKED***"
                  else
                      .
                  end
              )
          else
              .
          end
      )')

    export SEAA_MASKED_EXTRAVARS  
  fi
}

function setRunOptions {

    # set -a
    
    # Check if no extra file are passed in and there is a default extra-vars file and use it
    if [[ -z "${SEAA_EXTRA_VARS}" && -f "${SEAA_DEFAULT_EXTRAVARS}" ]]; then
            SEAA_EXTRA_VARS="@${SEAA_DEFAULT_EXTRAVARS}"
            isExtraVarsFileReference=true
    fi

    # Check if there are values to override for extra-vars JSON file
    # if [[ -n "$overrideValues" && "$isExtraVarsFileReference" == "true" ]]; then
    if [[ "$isExtraVarsFileReference" == "true" ]]; then


        # Validate File
        if ! [ -r  "${SEAA_EXTRA_VARS:1}" ]; then
            echo -e "ExtraVars file ${red}'${SEAA_EXTRA_VARS:1}'${reset} does not exist or can not be read."
            exit 99
        # else
        #     echo "ExtraVars file ${SEAA_EXTRA_VARS:1} file found."
        fi

        # Generate Overridden EXTRA JSON if override values exist for JSON file
        overrideAndMaskExtraVars "${SEAA_EXTRA_VARS}"
    # elif [[ -n "$overrideValues" ]]; then
    else

        # Display SEAA_EXTRA_VARS and set masked
        overrideAndMaskExtraVars
    fi

    #Run playbook
    # Validate File
    if ! [ -r  "${SEAA_INVENTORY_LOCATION}/${SEAA_INVENTORY}" ]; then
        echo -e " ${red}Inventory file:${reset} '${SEAA_INVENTORY_LOCATION}/${SEAA_INVENTORY}' does not exist or is not accessible"
        exit 99
    fi

    # Set up playbook run options
    RUNOPTIONS="-i ${SEAA_INVENTORY_LOCATION}/${SEAA_INVENTORY} -e @${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/variables/config/.config --flush-cache"

    # Add vault automation strategy to playbook run options
    if [[ -n "${SEAA_AUTOMATION_STRATEGY}" ]]; then
      # shellcheck disable=SC2034  # ev_automation_strategy is used as an extra var in deployment scripts
      ev_automation_strategy='{"seaa_automation_strategy": '${SEAA_AUTOMATION_STRATEGY}' }'
    fi

    # Add vault passwords file to playbook run options
    if [[ -n "${SEAA_ANSIBLE_VAULT_PASSWORD_FILE}" ]]; then
      RUNOPTIONS+=" --vault-password-file ${SEAA_ANSIBLE_VAULT_PASSWORD_FILE}"
    fi

    # Add vault-id to playbook run options
    if [[ -n "${SEAA_ANSIBLE_VAULT_PASSWORD_FILE}" && -n "${SEAA_ANSIBLE_VAULT_ID}" ]]; then
      RUNOPTIONS+=" --vault-id ${SEAA_ANSIBLE_VAULT_ID}"
    fi

    # set +a
}

function printTagStatus {

    # Check if tags are not provided
    if [[ "$has_tag" == "false" ]]; then
        echo -e "${yellow}Warning:${reset} no tags provided"
    else
        echo -e "${cyan}Running:${reset} with provided tag(s) '${SEAA_TAGS}'"
    fi

    # Check if skip tags areprovided
    if [[ "$has_skiptag" == "true" ]]; then
        echo -e "${yellow}Warning:${reset} skip tag(s) provided '${SEAA_SKIPTAGS}'"
    fi
}
