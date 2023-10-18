#!/bin/bash
# Smart Deploy Cloud Broker with automation strategy as generate_yaml on a single namespace


# Set automation strategy used values generate_deploy_yaml, deploy_yaml, generate_yaml, inline (to-be - deprecated)
# - "deploy_yaml" - deploy or undeploy resources using native YAML API
# - "generate_yaml" - generate Natvie YAML, script and readme files for deployment or undeployment
# - "generate_deploy_yaml" - generate Natvie YAML, script and readme files and deploy or undeploy resources using native YAML API
export SEAA_AUTOMATION_STRATEGY="generate_yaml" #"generate_yaml" # "generate_deploy_yaml" # "deploy_yaml" #
export SEAA_DEPLOY_STRATEGY="undeploy"
export DEPLOY=${2:-true} # DEPLOY
export SEAA_CONFIG_PATH_TO_SE_VARIABLES=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/variables

# ***********************************
# Pre-Req export Env/Ansible Variable to run Scenario
# ***********************************
# Set ENV variable to run playbook
export run_playbook_dir=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../scripts/run_playbooks


# ***********************************
# Pre-Req export Env/Ansible Variable to run Scenario
# ***********************************
export WORKING_DIR=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../../../seaa_testscripts/scenario6
export INVENTORY_LOCATION=${WORKING_DIR}/inventory
export INVENTORY=cb_zpm_undeploy.yaml
export YAML_OUTPUT_DIR=${WORKING_DIR}

# Set ansible verbosity
export VERBOSITY=4

# Flag to validate CRs on z/OS Endpoints
export VALIDATE_CRS=false

# Encrypt Secrets being deployed to OCP
export ENCRYPT_SECRETS=false

# Check for existence of Broker and deploy if it doesn't exist regardless of tags
export ZOSCB_SMART_DEPLOY=false

export ZPM_SMART_DEPLOY=false

# ***********************************
# Pre-Req export Env/Ansible Variable to run Scenario
# ***********************************
export ADMIN_NAMESPACES='"zstack-se-cb-zpm-und-gen"'

export tags=zoscb,zpm
export skiptags=


# Default extra-vasr file use for this test
extravars_file="${WORKING_DIR}/extravars/cb_zpm_undeploy_gen.json"

# Override extra-vars from default extr-vars file FOR DEPLOY
override_values='{
   "seaa_zoscb_smart_deploy": '$ZOSCB_SMART_DEPLOY',
   "seaa_purge_namespace": true,
   "seaa_deploy_strategy": "'$SEAA_DEPLOY_STRATEGY'",
   "seaa_zpm_smart_deploy": '$ZPM_SMART_DEPLOY',
   "seaa_automation_strategy": "'$SEAA_AUTOMATION_STRATEGY'",
   "seaa_yaml_output_dir": "'$YAML_OUTPUT_DIR'",
   "project_names": ['$ADMIN_NAMESPACES'],
   "seaa_deploy_validate_crs": '$VALIDATE_CRS',
   "seaa_encrypt_secrets": '$ENCRYPT_SECRETS'
}'

#PHASE 1 DEPLOY NAMESPACE for each OCP user
run_step=${DEPLOY}
# Admin - Deploy Admin Project and deploy SHARED Broker and ZPM to a single endpoint
$run_step && echo "Admin - UnDeploy Admin Project with Cloud Broker and ZPM"
$run_step && ${run_playbook_dir}/run-undeploy-oel-dev-env.sh -v=${VERBOSITY} -t=${tags} -st=${skiptags} -i=${INVENTORY} -i_loc=${INVENTORY_LOCATION} \
  -e="@$extravars_file" -ov="${override_values}"
