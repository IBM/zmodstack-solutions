# Solutions Enablement Ansible Automation (SEAA) framework for IBM Z and Cloud Modernization Stack

## Overview
 In this topic, we outline the [capabilities](/docs/guide/feature-list.md) and components of the SEAA framework. The framework provides a prescriptive model based on tags and configuration variables provided. These values determine how automation interacts with the underlying systems and a user. The framework offers the following components as outlined in the table below.

<!-- In this topic, we are providing an automation framework and some samples to help you enhance modernization journey by using the stack. The framework provides a prescriptive model based on tags and configuration variables provided. These values determine how automation interacts with the underlying systems and a user. The framework offers you the ansible components as outlined in the table below. -->

|**Components**|**Description**|
|----------------------|---------------|
|Ansible [variables](/ibm/seaa/ansible/variables/README.md)|Default and variable data used to define Red Hat® OpenShift® and z/OS system resources|
|Ansible [inventory](/ibm/seaa/ansible/playbooks/inventory/README.md)|To define multiple host and host variables used to deploy resources on OpenShift and z/OS endpoints.
|Ansible [playbooks](/ibm/seaa/ansible/playbooks/README.md), [tasks](/ibm/seaa/ansible/tasks/README.md), [roles](/ibm/seaa/ansible/roles/README.md), [run_playbook scripts](/ibm/seaa/scripts/run_playbooks/README.md)|To deploy stack components
|Admin shell [scripts](/ibm/seaa/scripts/admin/README.md) |To run administer stack resources on OpenShift cluster and z/OS endpoints. 

See the [configuration](/ibm/seaa/ansible/variables/config/seaa_config.yaml) variables used to control how automation runs along with [tags](/docs/guide/seaa-tags.md) used for the specific [playbook](/ibm/seaa/ansible/playbooks/README.md) being run.

## Framework Architectural Diagram
![Architectural Diagram](../images/seaa-architectural-diagram.png)

---
<!-- 
## Automated Solutions
The table here provides an overview of solutions that are considered for automation.
<table>
<thead>
  <tr>
    <th>Product</th>
    <th>Automation Solution</th>
    <th>Supported</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4">IBM z/OS Cloud Broker using <a href="https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/2023.1?topic=azrpzcb-performing-zos-cloud-broker-tasks-via-kubernetes-native-api-calls" target="_blank" rel="noopener noreferrer">Kubernetes native APIs</a></td>
    <td>Deploy IBM z/OS Package Manager</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM Z Open Automation Utilities</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM Open Enterprise Languages</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM IMS Operator</td>
    <td>WIP</td>
  </tr>
  <tr>
    <td>Wazi DevSpaces</td>
    <td colspan="2">Not automated (under consideration)</td>
  </tr>
  <tr>
    <td>Wazi Sandbox</td>
    <td colspan="2"><ul><li>Not automated (under consideration)</li><li>Secure with RACF Operator - Not automated (under consideration)</li></ul>
</td>
  </tr>
  <tr>
    <td>z/OS Connect EE</td>
    <td colspan="2">Not automated (under consideration)</td>
  </tr>
</tbody>
</table> -->
  
<!-- ## Content
- _acceptance_test - *IBM Internal Use ONLY* - used to verify z/OS Cloud and Modernization Stack components - **Work in Progress**
- ansible - Parent directory for ansible artifacts
  - [roles](ansible/roles) - ansible roles for solution enablement
  - [tasks](ansible/tasks) - common ansible task for solution enablement
  - [playbooks](ansible/playbooks) - ansible playbooks for solution enablement
  - [variables](ansible/variables) - ansible variables used by roles, task and playbooks, and to config automation
- [scripts](scripts) - directory with bash scripts for ansible playbooks and admin task
- [collections](collections) - directory with collections used in playbooks - **Work in Progress**
 -->

<!-- # Configuring and running automation
Please see below the information about minimum requirements, configuring, and running automation from this repo.
*** -->
---
## Minimum Requirements
Listed below are the minimum requirements for OpenShift and z/OS endpoints.
<!-- -<!-- - - Dev Environment:
- ansible-lint -  python -m pip install ansible-lint -->

**Openshift Cluster - v4.9 or later**
- OpenShift cluster with [IBM Z and Cloud Modernization Stack](https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/latest?topic=installing) entitlement keys for the following certified operators installed:
  - z/OS Cloud Broker<br>

**z/OS endpoint** <!--  (when running z/OS [admin scripts/playbooks](ansible/scripts/admin)) ** Work in Progress  -->
- See z/OS storage [requirements](https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/2023.1?topic=planning-system-requirements#z-os-storage)
- [Python 3.8](https://www.python.org/downloads/) or later - for connecting and running ansible playbooks on zos endpoints
- [ZOAU 1.1.0](https://www.ibm.com/docs/en/wdfrhcw/1.4.0?topic=components-z-open-automation-utilities) or later -  for scripts that require ZOAU commands <br>


---
## Next steps [getting started workstation](/docs/setup/get-started-workstation.md) -or- [getting started CI/CD](/docs/setup/get-started-cicd.md) 
<!-- ## Running automation locally -->
<!-- ### 1. Configure Workstation
a. Export the following environment variables on local machine.
  - **SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS** - the path to your cloned solutions-enablement repo **[ansible](ansible)** directory.
  - **ANSIBLE_FILTER_PLUGINS** - the path to the filter plugins directory appended to the ansible defaults.
  - **ANSIBLE_LIBRARY** - the path to the library plugins directory appended to the ansible defaults.

b. Optional: **SEAA_CONFIG_PATH_TO_SE_VARIABLES** - the path to ansible variables to use in seaa automation, if different from default location **[ansible/variables](ansible/variables)** directory.<br>
    **Example for unix-like OS terminal:**<br>
    ```
    export SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS=~/git/zstack/solutions-enablement/scenarios/ansible
    export ANSIBLE_FILTER_PLUGINS=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/filter:~/.ansible/plugins/filter:/usr/share/ansible/plugins/filter
    export ANSIBLE_LIBRARY=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/validation:~/.ansible/plugins:/usr/share/ansible/plugins

    ```
    **Note:** These environment variables can also be added to **.bash_profile** or to environment variables for specific OS.

c. Create Ansible Config file in home directory with the following content, see this [link](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) for details on Ansible config:
  ```
  [defaults]
  # Number of forks Ansible will use to execute tasks on target hosts.
  forks = 25

  # This option preserves variable types during template operations
  jinja2_native=True

  # Colon separated paths in which Ansible will search for Roles.
  roles_path = ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../../../zoscb_e2e/roles:${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/roles

  # Toggle to control displaying skipped task/host entries in a task in the default callback
  display_skipped_hosts = false

  [ssh_connection]
  # Improvements performance when enabled.
  pipelining = True
  ``` -->

<!--   
### 1. Review and configure default Ansible variables
Review documentation for [variables](ansible/variables) and make any changes as required to configuration or defaults based on automation run.

### 2. Create Default Inventory
Review [sample-inventory.yaml](ansible/playbooks/inventory/sample-inventory.yaml) file and use it to create a local default **inventory.yaml** file in your cloned solutions-enablement repo **[inventory](ansible/playbooks/inventory)** directory. -->

<!--
# Ansible Inventory Notes
- simple-inventory.yaml - ansible inventory file for deploying/undeploying z cloud and modernization stack components across ocp clusters, zos endpoints and ocp projects. Edit this file and rename per usecase/scenarios.

- sample-inventory.yaml - ansible inventory file for deploying/undeploying z cloud and modernization stack components across ocp clusters, zos endpoints and ocp projects. Edit this file and rename per usecase/scenarios.

- All Group - "**all**" inventory default variables for inventory these values will apply to all group variables in iventory unless overrode by the specific group/host
- OCP Hosts Group - "**ocphosts**" grouped variables for Openshift clusters
- z/OS Endpoints Group - "**zosendpoints**" grouped variables for z/OS endpoints

-->
<!-- 
### 3. Run Playbook Script for Deploying Open Enterprise Languages (OEL) Development Environments-aaS
a. 'CD' to the **[run_playbooks](scripts/run_playbooks)** directory in cloned repo and run one or more of the following scenarios by using commands provided here.

  - #### Deploy **z/OS Cloud Broker** and **z/OS Package Manager** - ONLY:<br>
    ```
    ./run-deploy-oel-dev-env.sh
    ```
  - #### Deploy **z/OS Cloud Broker**, **z/OS Package Manager** and **All zProduct Sub-Operators, No product instances**.<br>
    ```
    ./run-deploy-oel-dev-env.sh --tags=oel-dev --extra-vars=seaa_deploy_software_instances=false
    ```
 - #### Deploy **z/OS Cloud Broker**, **z/OS Package Manager** with **ZOAU** and **Python**:<br>
    ```
    ./run-deploy-oel-dev-env.sh --tags=python,zoau
    ```
 - #### Undeploy **z/OS Cloud Broker**, **z/OS Package Manager** and **All zProduct Sub-Operators or Instances**.<br>
    ```
    ./run-undeploy-oel-dev-env.sh --tags=oel-dev
    ```
## Using SEAA Test Harness
 - **TODO** - work in progress 
 
 -->

