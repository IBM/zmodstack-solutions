<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->
# Role: 'zpm'
This role and the scenario of the same name (`zpm`) within it can be used to install, verify and destroy z/OS Package Manager on a z/OS endpoint through OpenShift by importing the associated operator collection and creating custom resources on an OpenShift cluster.


## Requirements
  - [kubernetes.core](https://galaxy.ansible.com/kubernetes/core) (formerly, `community.kubernetes`): Automates the provisioning and management of OpenShift clusters and resources within them.


## Role Variables
This role uses the following variables. Some of the values of these variables can be modified as required.

### Environment Variables
  - The below environment variables are read by each role. You must set the below environment variables before running any automation.
    - `OCP_CLUSTER_HOSTNAME`
    - `OCP_CLUSTER_PORT`
    - `OCP_CLUSTER_AUTH_TOKEN`
    <!-- - `namespace_name` -->
    - `zpm_registry_host`
    - `zpm_registry_user`
    - `zpm_registry_password`

### External variables from the role 'ocp_cluster'
  - Refer to variables that are internal to the role 'ocp_cluster' [here](<NEED_URL2>).

### Variables internal to this role
  - From `zoscb-e2e/zpm/vars/main.yml`
      - `zos_package_manager` (type `dict`): Openshift custom resource information required to install Z/OS Package Manager on a z/OS endpoint
      - `zos_package_manager_diagnostics` (type `dict`): Openshift custom resource information required to diagnose Z/OS Package Manager on a z/OS endpoint


## Dependencies
  - Role [ocp_cluster](https://github.com/IBM/zmodstack-solutions/blob/main/ibm/zoscb_e2e/roles/ocp_cluster)


## Using this role
This role contains the scenario 'zpm' in the directory `zoscb-e2e/zpm/molecule/zpm`. The 'zpm' scenario can be used to install, verify and uninstall z/OS Package Manager on a z/OS endpoint. Modify any of the above mentioned variables as required and following the instructions below.

### Install & Verify ZPM
  1. Use the role 'ocp_cluster' to bootstrap an OpenShift cluster by running the following command. Detailed instructions on bootstrapping an OpenShift cluster are available [here](https://github.com/IBM/zmodstack-solutions/blob/main/ibm/zoscb_e2e/roles/ocp_cluster/README.md).

      ```
      $ molecule -vv test -s ocp_cluster --destroy=never
      ```

  2. Copy the ZPM operator collection tar.gz file that should be used to install ZPM into the `zoscb-e2e/zpm/oc_file/` directory. This file will be automatically picked up and imported as an operator collection in the OpenShift cluster. Note: The `zoscb-e2e/zpm/oc_file/` directory must only contain the one operator collection file that needs to be imported and nothing else, otherwise, the import will fail.

      ```
      $ rm -rf zoscb-e2e/zpm/oc_file/* && cp <filepath_to_zpm_targz_file>/<zpm_targz_file> zoscb-e2e/zpm/oc_file/
      ```

  3. Change into this directory in the CLI and run the following molecule command to automatically import the copied operator collection into the bootstrapped OpenShift cluster, create a sub-operator config (map the collection to the specified z/OS endpoint) and create the `ZosPackageManager` and `ZosPackageManagerDiagnostics` custom resources in the cluster, which install ZPM on the z/OS endpoint. It will also run the `molecule verify` step to verify that all the resources are created successfully.

      ```
      $ molecule -vv test -s zpm --destroy=never
      ```

### Uninstall ZPM
  1. To uninstall ZPM on a z/OS endpoint, change into this directory and run the following command to automatically uninstall ZPM, delete the `ZosPackageManager` and `ZosPackageManagerDiagnostics` custom resources and the sub-operator config, remove the imported operator collection from the namespace, as well as, delete the operator collection tar.gz file locally within the `zoscb-e2e/zpm/oc_file/` directory.

      ```
      $ molecule -vv destroy -s zpm
      ```

      Note: Alternatively, not using the `--destroy=never` option in the `molecule test` command would have destroyed the created resources automatically. However, it is best practice to separately destroy resources with the `molecule destroy` command.


## Author Information
  - Naman Patel (Email: naman.patel@ibm.com)
  - Anthony Randolph (Email: acrand@us.ibm.com)
