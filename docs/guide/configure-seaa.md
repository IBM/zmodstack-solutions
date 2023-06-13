<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->

# Configure workstation
Complete the following steps to configure the framework to run on your workstation.

---
## Export the following environment variables on your workstation.
  
  - **SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS** - the path to your cloned solutions-enablement repo **[ansible](../../ibm/seaa/ansible)** directory.
  - **ANSIBLE_FILTER_PLUGINS** - the path to the filter plugins directory appended to the ansible defaults.
  - **ANSIBLE_LIBRARY** - the path to the library plugins directory appended to the ansible defaults. 

  - (Optional) **SEAA_CONFIG_PATH_TO_SE_VARIABLES** - the path to ansible variables directory to use with the framework, if different from default location **[ansible/variables](../../ibm/seaa/ansible/variables)** directory.<br>

- **Example for unix-like OS terminal:**<br>
    ```
    export SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS=~/git/zmodstack-solutions/ibm/seaa/ansible
    export ANSIBLE_FILTER_PLUGINS=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/filter:~/.ansible/plugins/filter:/usr/share/ansible/plugins/filter
    export ANSIBLE_LIBRARY=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/validation:~/.ansible/plugins:/usr/share/ansible/plugins

    ```
    **Note:** These environment variables can also be added to **.bash_profile** or to environment variables for a specific OS.

---
## (Optional) Create Ansible config file in the home directory    
  
  Save the following content to an '.ansible.cfg' file in your home directory, see this [link](https://docs.ansible.com/ansible/latest/reference_appendices/config.html) for details on Ansible config files. Having this ansible config file will allow you to run the framework script from other locations on your workstation.
  
    
    [defaults]
    # Number of forks Ansible will use to execute tasks on target hosts.
    forks = 25

    # This option preserves variable types during template operations
    jinja2_native=True

    # Colon separated paths in which Ansible will search for Roles.
    roles_path = ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/../../zoscb_e2e/roles:${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/roles

    # Toggle to control displaying skipped task/host entries in a task in the default callback
    display_skipped_hosts = false

    [ssh_connection]
    # Improvements performance when enabled.
    pipelining = True
    
---    
## Next steps [run locally](../guide/run-seaa-locally.md) -or- [back to framework guide](../guide/README.md)
