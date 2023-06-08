#!/bin/bash
#
# Description:
# This Script will purge ALL projects with Broker resources from OCP server that name or description matches filter provided.
# By default this script will run a TestRun and display all the resources to-be deleted, to actually delete resources
# you have to provide '--testrun=false' parameter.
#
# For additional usage information use "--help" flag as input to script.
#
# Example to run script:
#
# To see all resource that will be purged from OCP server with the '** seaa automated' in the projects name or description
# ./purge-all-broker-resources.sh --filter='** seaa automated'
# To purge all projects from OCP server with the '** seaa automated' in the projects name or description
# ./purge-all-broker-resources.sh --filter='** seaa automated' --testrun=false
# To purge a specific list of 'project-names' from OCP server with the '** seaa automated' in the projects name or description
# ./purge-all-broker-resources.sh --filter='** seaa automated' --allowed_projects='project-name project-name2' --testrun=false

# zstack-se-engage-126-test

# **************************************************************************************************#

# Print usage
function printUsage {
  echo "WARNING!!! this script will purge all z/OS Cloud Broker resources from project(s) matched by '--filter' on OCP hosted logged into"
  echo "Usage: $(basename "$0"): "
  echo "    --server=* Open Shift server to login to, the value has the format of 'https://<host>:<port>'"
  echo "    --token=* API token used to connect to the Open Shift server."
  echo "    --filter=* Filter matches project namespace(s) based on name or description to purge. (REQUIRED)"
  echo "    --allowed_projects=(list) Name of Openshift project namespaces(s) that can be purged, if not provided all projects that match filter will be purged"
  echo "    --unallowed_projects=(list) Name of Openshift project namespaces(s) that can be purged, if not provided all projects that match filter will be purged"
  echo "    --bycomponent=(list) Name of zStack Component CR ResourceKinds to purge as apart of Openshift resource, default(broker)"
  echo "    --testrun=(true | false) set this to 'false' to actually perform purge, default(true)."
  echo "    --remove_finalizers=(true | false) set this to 'false' attempt to delete resources with finalizers, default(true)."
  echo "    --debug set to print out debug trace, default(false)."
  echo "    --delete_namespace=(true | false) set this to 'false' in multinamespace operation so admin soc doesn't fail"
  echo "    --automated_run=(true | false) set this to 'true' to skip logged in prompt in automation"
}

# Parse command line options
function parseCommandLine {
  for i in "$@"; do

      case $i in
          --server=*)
              export OCP_SERVER=${i#*=}
      ;;
          --token=*)
              export OCP_TOKEN=${i#*=}
      ;;
          --filter=*)
              export projectFilter=${i#*=}
      ;;
          --allowed_projects=*)
              allowed_projects=("${i#*=}")
      ;;
          --unallowed_projects=*)
              unallowed_projects=("${i#*=}")
      ;;
          --bycomponent=*)
              bycomponent="${i#*=}"
      ;;
          --testrun=*)
              export testrun=${i#*=}
      ;;
          --remove_finalizers=*)
              export remove_finalizers=${i#*=}
      ;;
          --delete_namespace=*)
              export delete_namespace=${i#*=}
      ;;
          --automated_run=*)
              export automated_run=${i#*=}
      ;;
          --debug)
              export isDebug=true
              set -x

      ;;
          *)
            echo "Unrecognized option: $i"
            printUsage;
            exit 1;
      ;;
      esac
  done
}

############################################################################################################################################
# Start Script OCP Login Util
############################################################################################################################################

# Log errors to terminal
function logError() {
  echo -e "\n\033[1;31m${1}\033[00m"
  # if [[ "$continue_on_error" = false ]]; then
  #   exit 1
  # fi
}

# Log warning to terminal
function logWarning() {
  echo -e "\n\033[1:32m${1}\033[00m"
}
# Log message t terminal
function logMessage() {
  echo -e "\n\033[1;34m${1}\033[00m"
}

# Login to Open Shift server
function loginOCP() {

  # Set flag to check if logged in
  isLoggedIn=false

  # Check if is already logged in to OCP
  if oc whoami >/dev/null 2>&1; then
    # Set logged on username
    logged_user="$(oc whoami 2>/dev/null)"
    logged_server="$(oc whoami --show-server 2>/dev/null)"
    # Print logged in user
    logMessage "Logged in as $logged_user on $logged_server"

    # Get server values 
    logged_server_value="$(echo "$logged_server" | sed -e "s#^[^/]*//\([^:/]*\).*#\1#")"
    target_ocphost_value="$(echo "$OCP_SERVER" | sed -e "s#^[^/]*//\([^:/]*\).*#\1#")"

    # Verify logged into the corrct server
    if [[ "${target_ocphost_value}" == "${logged_server_value}" ]]; then
      isLoggedIn=true
    else
      # Check if server name not provided
      if [ -z "$OCP_SERVER" ]; then
         # Confirm script is being quit
        if [ "${automated_run}" == "true" ]; then
          isLoggedIn=true
        else
          read -rp "Are you sure '$logged_server' is the right OCP host to purge? [y/N]" -n 1 -r
          if [[ $REPLY =~ ^[Yy]$ ]]; then
            isLoggedIn=true
          else
            isLoggedIn=false
          fi
          echo
        fi
      else
        logMessage "Logged into wrong host, will login to $target_ocphost_value ..."
        # log_out=$(oc logout)
        isLoggedIn=false
      fi
    fi
  fi

  # if not logged int to OCP loggin
  # if [[ $? -ne 0 ]]; then
  if [[ "$isLoggedIn" == "false" ]]; then

    # Log message for login attempt
    logMessage "Attempt to login to ${OCP_SERVER} ... "

    # Check if OCP_TOKEN is set to None by default
    if [[ "$OCP_TOKEN" == "None" ]]; then
      # Set OCP_TOKEN to empty string if it is None
      OCP_TOKEN=''
    fi

    # Check if ocp server and token are provided
    if [[ -n "$OCP_TOKEN" && -n "$OCP_SERVER" ]]; then
      # Login Open Shift
      # oc login --token="${OCP_TOKEN}" --server="${OCP_SERVER}"
      # if [[ $? -ne 0 ]]; then
      if ! oc login --token="${OCP_TOKEN}" --server="${OCP_SERVER}"; then
        logError "Unable to login to ${OCP_SERVER} "
        exit 1
      fi
    else # OCP Token and Server not provided

      # Check if server is empty
      if [[ -z "$OCP_SERVER" ]]; then
        # Read OCP server from user input
        read -rp "Enter Open Shift server in the format of 'https://<host>:<port>': " OCP_SERVER
      fi

      # Check if token is empty
      if [[ -z "$OCP_TOKEN" && -n "$OCP_SERVER" ]]; then
        # Read OCP token from user input
        read -rp "Enter API token for Open Shift server $OCP_SERVER: " OCP_TOKEN
      fi

      # Login Open Shift
      # oc login --token="${OCP_TOKEN}" --server="${OCP_SERVER}"
      # if [[ $? -ne 0 ]]; then
      if ! oc login --token="${OCP_TOKEN}" --server="${OCP_SERVER}"; then
        logError "Unable to login to ${OCP_SERVER} "
        exit 1
      fi
    fi
  fi

}
############################################################################################################################################
# End Script OCP Login Util
############################################################################################################################################

# Purge ResourceKinds for z/OS Cloud Broker
function purgeBroker() {

  if [[ "$bycomponent" == "all" || "$bycomponent" == "broker" ]]; then

      # Purge IMS Operator
      purgeResources TMDB

      # Purge ZPM post v2.0.0 Product Resources
      purgeResources ZosProductValidate
      purgeResources ZosProductInstall

      # - SUBOP INSTANCES pre-ZPM v2.0.0
      purgeResources ZOAUInstance
      purgeResources ValidateZOAU
      purgeResources PythonInstance
      purgeResources ValidatePython
      # Resource no longer available
      # purgeResources OpenCPPInstance
      # purgeResources ValidateOpenCPP
      purgeResources NodejsInstance
      purgeResources ValidateNodejs
      purgeResources JavaInstance
      purgeResources ValidateJava
      purgeResources GoInstance
      purgeResources ValidateGo

      purgeResources ZosPackageManager
      purgeResources ZosPackageManagerDiagnostics

      # - SUBOPS
      purgeResources SubOperatorConfig

      # - OCS
      purgeResources OperatorCollection

      # DELETE ZOS ENDPOINT
      purgeResources ZosEndpoint

      # DELETE INSECURE ROUTE
      purgeResources Route

      # DELETE Z CLOUD BROKER INSTANCE
      purgeResources ZosCloudBroker

  fi
}

# Purge ResourceKinds for Wazi Dev Spaces
function purgeDevWorkspaces() {

  if [[ "$bycomponent" == "all" || "$bycomponent" == "devspaces" ]]; then
    # TODO - Get More ResourceKinds for DevWorkspaces
    purgeResources DevWorkspaceRouting
    purgeResources DevWorkspace

  #  tso "UMOUNT FILESYSTEM('OMVS250F.ROOT') REMOUNT(RDWR)"
  fi

}

# Purge ResourceKinds for Wazi Dev Spaces
function purgeZosConnect() {

  if [[ "$bycomponent" == "all" || "$bycomponent" == "zosconnect" ]]; then
    # TODO - Get More ResourceKinds for ZosConnect
    purgeResources ZosConnect
  fi

}

# Main function to run script
function main() {

    #Parse command line
    parseCommandLine "$@"

    # Check if testrun
    if [[ "$testrun" == "true" ]]; then
      logWarning "!!! NOT DELETING RESOURCES, TESTRUN ONLY !!!"
    fi

    # Verify required parameters
    if [[ -z "$projectFilter" ]]; then
      echo "Not all required parameters provided. Please check usage below and re-run script with all required parameters:" >&2
      printUsage
      exit 4
    fi

    echo "PROJECT FILTER '$projectFilter'"

    if [ "${#allowed_projects[@]}" -gt 0 ]; then
      echo "PROJECT(s) ALLOWED to be purged: " "${allowed_projects[@]}"
    fi

    if [ "${#unallowed_projects[@]}" -gt 0 ]; then
      echo "PROJECT(s) UNALLOWED to be purged: " "${unallowed_projects[@]}"
    fi

    # Login OCP server
    loginOCP

    # Get projects that match filter criteria
    filtered_namespaces=()
    while IFS='' read -r line; do filtered_namespaces+=("$line"); done < <(oc get Project -A | grep -F "$projectFilter" | awk '{print $1}')
    # Check if any projects exist based on filter
    if [ "${#filtered_namespaces[@]}" -gt 0 ]; then
      echo "${#filtered_namespaces[@]} project namespaces matched with filter '$projectFilter' : " "${filtered_namespaces[@]}"

      purgeBroker

      purgeDevWorkspaces

      # DELETE Z CLOUD BROKER SUBSCRIPTION
      purgeResources Subscription
      # DELETE CLUSTER SERVICE VERSION (OPERATOR)
      purgeResources ClusterServiceVersion

      # DELETE OPERATOR GROUP
      purgeResources OperatorGroup


      # DELETE PERSISTENT VOLUME CLAIM
      purgeResources PersistentVolumeClaim

      # DELETE NAMESPACE
      if [ "${delete_namespace}" == true ]; then
        purgeResources Project
      fi

    else

      echo "No namespace found for filter '$projectFilter'"

    fi

}

# Check if namespace can be purged or if it is in the NOT allowed project array
function canPurgeProject() {
    # Set target value to see if it in allowed or filtered project list
    target_value=${1}

    # Check if not allowed project is zero which would mean all projects found can be removed
    if [ "${#unallowed_projects[@]}" -eq 0 ]; then
      return 0
    fi

    # Iterate over all unallowed project namespaces
    for unallowed_project in "${unallowed_projects[@]}"; do
      # Check is target value is not allowed to be purged
      if [[ "$unallowed_project" == "$target_value" ]]; then
        echo "Resource '${2}' '${3}' is contained in UNALLOWED project '$unallowed_project', CANNOT be deleted ..."

        return 1
      fi
    done

    # Not on unallowed list okay to purge resources
    return 0
}

# Check if namespace it in allowed and filter project array
function isNamespaceContained() {
    # Set target value to see if it in allowed or filtered project list
    target_value=${1}

    # Check if allowed project is provided if not set to list of filtered projects
    if [ "${#allowed_projects[@]}" -eq 0 ]; then
      allowed_projects=("${filtered_namespaces[@]}")
    fi

    # Iterate over all allowed project namespaces
    for allowed_project in "${allowed_projects[@]}"; do
      # Check is target value is allowed to be purged
      if [[ "$allowed_project" == "$target_value" ]]; then
        # Iterate over all projects matched name or description matched
        for filter_namespace in "${filtered_namespaces[@]}"; do
            # Check if filtered project namespace is same as target value
            if [[ "$filter_namespace" == "$target_value" ]]; then
                return 0
            fi
        done
      fi
    done

    # echo "$target_value not in filtered projects"
    return 1
}

function debug() {

    if [[ "$isDebug" == true ]]; then
      echo "$1"
    fi
}

function purgeResources() {
  resourceType=${1}

  if [[ ${resourceType} == "Project" ]]; then
    # Set array of resourcenames to filtered project names
    resourcenames=("${filtered_namespaces[@]}")
    debug "Resource Names: " "${resourcenames[@]}"

    # Set array of namespaces to filtered project namespaces
    resourcenamespaces=("${filtered_namespaces[@]}")
    debug "Resource Namespaces: " "${resourcenamespaces[@]}"

  else
    # Set array of resourcenames to ALL names return by OC get
    resourcenames=()
    while IFS='' read -r line; do resourcenames+=("$line"); done < <(oc get "${1}s" -A | awk '{print $2}' | awk '(NR>1)')
    
    debug "Resource Names: " "${resourcenames[@]}"

    # Set array of ALL namespaces that contain resource
    resourcenamespaces=()
    while IFS='' read -r line; do resourcenamespaces+=("$line"); done < <(oc get "$1" -A | awk '{print $1}' | awk '(NR>1)')

    debug "Resource Namespaces: " "${resourcenamespaces[@]}"
  fi

  index=0

  # Iterate over resource names that contain resource
  for resourceName in "${resourcenames[@]}"; do

        debug "'${resourceType}' ${resourceName} in ${resourcenamespaces[$index]}"

        # Check if resource's namespace is in the filter project array
        if canPurgeProject "${resourcenamespaces[$index]}" "${resourceType}" "${resourceName}" && isNamespaceContained "${resourcenamespaces[$index]}"; then
          echo "Resource '${resourceType}' '${resourceName}' is contained in filtered projects '${resourcenamespaces[$index]}', delete it ..."
          # if [[ ${resourceType} == "ZosCloudBroker" ]]; then
          #   echo "resource ${resourcenamespaces[$index]}"
          #   # oc get zoscloudbroker -n "${resourcenamespaces[$index]}" -o jsonpath='{.items[0].metadata.name}'
          #   zoscb_instance_newname="$( oc get zoscloudbroker -n "${resourcenamespaces[$index]}" -o jsonpath='{.items[0].metadata.name}' )"
          #   echo "Broker ${zoscb_instance_newname}"
          #   exit 99
          # fi  
          # Check if this is a testrun
          if [[ ${testrun} == "false" ]]; then
            # Check if resource is Project type
            if [[ ${resourceType} == "Project" ]]; then
              # set -x

              # Delete Namespace for project
              oc delete namespace "${resourceName}"

              # Delete Project
              oc delete "${resourceType}" "${resourceName}" --ignore-not-found 

              # set +x
            else
              if [[ ${remove_finalizers} == "true" ]]; then
                debug "Patch resource finalizer ... "
                #   set -x
                # Patch resource finalizer to null so it can be deleted
                oc patch "${resourceType}" "${resourceName}" --namespace "${resourcenamespaces[$index]}" --type=merge -p '{"metadata": {"finalizers":null}}'
                #   set +x
                # For DevWorkspace purge ??
                #   oc patch checluster.org.eclipse.che/${resourcenamespaces[$index]}  --namespace "${resourcenamespaces[$index]}"  --type=merge -p '{"metadata": {"finalizers":null}}'
              fi
              # Check if resource is ZosCloudBroker type
              if [[ ${resourceType} == "ZosCloudBroker" ]]; then

                set -x

                
                #Get zoscb instance name
                # zoscb_instance_name=()
                # while IFS='' read -r line; do zoscb_instance_name+=("$line"); done < <(oc get zoscloudbroker -n "${resourcenamespaces[$index]}" -o jsonpath='{.items[0].metadata.name}')
                
                zoscb_instance_name="$( oc get zoscloudbroker -n "${resourcenamespaces[$index]}" -o jsonpath='{.items[0].metadata.name}' )"
         
                # Delete CatalogSource, Deployment, Service, and Service Account associated with the namespace
                # ibm-zoscb-registry-zoscloudbroker-josh-test-auto-admin
                oc delete CatalogSource "ibm-zoscb-registry-${zoscb_instance_name}-${resourcenamespaces[$index]}" -n openshift-marketplace --ignore-not-found
                oc delete svc "ibm-zoscb-registry-${zoscb_instance_name}-${resourcenamespaces[$index]}" -n openshift-marketplace --ignore-not-found
                oc delete sa "ibm-zoscb-registry-${zoscb_instance_name}-${resourcenamespaces[$index]}" -n openshift-marketplace --ignore-not-found
                oc delete Deployment "ibm-zoscb-registry-${zoscb_instance_name}-${resourcenamespaces[$index]}" -n openshift-marketplace --ignore-not-found
                
                set +x

              fi

              # Delete Resource
              oc delete "${resourceType}" "${resourceName}" --namespace "${resourcenamespaces[$index]}"
              #   set +x
            fi
         fi
        fi

        # Bump index for resource namespace
        (( index++ )) || true
 
  done

}
# Set defaults
projectFilter=''
testrun=true
isDebug=false
bycomponent=broker
remove_finalizers=true
delete_namespace=true
automated_run=false
main "$@"