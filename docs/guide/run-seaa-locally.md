# Running locally
Follow the steps below to run the framework on your workstation.

---
## Review and configure default Ansible variables
(Optional - TL;DR) review documentation for [variables](/ibm/seaa/ansible/variables/README.md) and make any changes as required to deploy desired versions or configuration.

---
## Create default inventory
Review [sample-inventory.yaml](/ibm/seaa/ansible/playbooks/inventory/sample-inventory.yaml) file and use it to create a local default '**inventory.yaml**' file in your cloned zmodstack-solutions repo **[inventory](/ibm/seaa/ansible/playbooks/inventory)** directory.
<!--
# Ansible Inventory Notes
- simple-inventory.yaml - ansible inventory file for deploying/undeploying z cloud and modernization stack components across ocp clusters, zos endpoints and ocp projects. Edit this file and rename per usecase/scenarios.

- sample-inventory.yaml - ansible inventory file for deploying/undeploying z cloud and modernization stack components across ocp clusters, zos endpoints and ocp projects. Edit this file and rename per usecase/scenarios.

- All Group - "**all**" inventory default variables for inventory these values will apply to all group variables in inventory unless overrode by the specific group/host
- OCP Hosts Group - "**ocphosts**" grouped variables for Openshift clusters
- z/OS Endpoints Group - "**zosendpoints**" grouped variables for z/OS endpoints

-->
---
## Run playbook script for deploying Open Enterprise Languages (OEL) development environments-aaS
'CD' to the **[run_playbooks](scripts/run_playbooks)** directory in cloned repo and run one or more of the following scenarios with 'default' configuration values using commands provided here.

  - #### Deploy **z/OS Cloud Broker** and **z/OS Package Manager** - ONLY:<br>
    ```
    ./run-deploy-oel-dev-env.sh
    ```
  - #### Deploy **z/OS Cloud Broker**, **z/OS Package Manager** and **All zProduct Sub-Operators, without validating product instances**.<br>
    ```
    ./run-deploy-oel-dev-env.sh --tags=oel-dev --extra-vars=seaa_deploy_validate_crs=false
    ```
 - #### Deploy **z/OS Cloud Broker**, **z/OS Package Manager** with **ZOAU** and **Python**:<br>
    ```
    ./run-deploy-oel-dev-env.sh --tags=python,zoau
    ```
 - #### Undeploy **z/OS Cloud Broker**, **z/OS Package Manager** and **All OEL Instances**.<br>
    ```
    ./run-undeploy-oel-dev-env.sh --tags=oel-dev
    ```
**[View available tags for run script and playbook.](/docs/guide/seaa-tags.md)**    

---
## Creating your own deployment scripts
  - **TODO** - work in progress 

---  
## Using generated deployment scripts
  - **TODO** - work in progress 

---
## Using SEAA Test Harness
 - **TODO** - work in progress 

---    
## Next steps [troubleshooting](/docs/guide/troubleshooting.md) -or- [back to framework guide](/docs/guide/README.md)