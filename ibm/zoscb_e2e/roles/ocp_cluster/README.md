# Role: 'ocp_cluster'
This role and the scenario of the same name (`ocp_cluster`) within it can be used to bootstrap an OpenShift cluster.


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

### Variables internal to this role
  - From `zoscb-e2e/ocp_cluster/vars/main.yml`
      - `ocp_cluster` (type `dict`): Credentials for the OpenShift cluster
      - `artifactory` (type `dict`): Credentials for the CICD artifactory
      - `project_namespace` (type `dict`): Project/Namespace to create within the cluster
      - `persistent_volume_claim` (type `dict`): Specifications for the Persistent Volume Claim to be created in the namespace
      - `operator_group` (type `dict`): Specifications for the Operator Group to be created in the namespace
      - `broker_subscription` (type `dict`): Specifications for the Broker Subscription to be created in the namespace
      - `broker_instance` (type `dict`): Specifications for the Cloud Broker Instance to be created in the namespace
      - `route` (type `dict`): Specifications for the Route to be created in the namespace
  - From `zoscb-e2e/ocp_cluster/vars/endpoints.yml`
      - `endpoint` (type `dict`): Specifications for the endpoint to be created in the namespace


## Dependencies
N/A


## Using this role
This role contains the scenario 'ocp_cluster' in the directory `zoscb-e2e/ocp_cluster/molecule/ocp_cluster`. The 'ocp_cluster' scenario can be used to bootstrap an OpenShift cluster, verify the resources that get created in it and destroy them at the end of the run.

### Define OpenShift cluster credentials
  - To run the end-to-end automation, you are required to set the above mentioned environment variables. This will define all the secret credentials required.


### Define OpenShift cluster resources
  - While the above mentioned variables in file `zoscb-e2e/ocp_cluster/vars/main.yml` have default values already set, some of those values can be modified as required or can be left as is. This information will be used to create all the OCP resources on a cluster.
  - You should also update the `zoscb-e2e/ocp_cluster/vars/endpoints.yml` file to set your endpoint's information.

### Bootstrap and verify the OpenShift cluster
  1. Once the cluster credentials and cluster resources are defined in their respective variable files, change into this directory in the CLI. Then, an OpenShift cluster can be bootstrapped using the following command.

      ```
      $ molecule -vv test -s ocp_cluster --destroy=never
      ```

      Note: Since the bootstrapped cluster is required if you want to continue to test the sub-operators, the `--destroy=never` option is specified to prevent Molecule from automatically destroying the created resources after verifying them.

### Delete resources to clean up the OpenShift cluster
  1. To automatically delete all the created OCP resources from a cluster, run the following command.
      ```
      $ molecule -vv destroy -s ocp_cluster
      ```

      Note: Alternatively, not using the `--destroy=never` option in the `molecule test` command would have destroyed the created resources automatically. However, it is best practice to separately destroy resources with the `molecule destroy` command.


## Author Information
- Naman Patel (Email: naman.patel@ibm.com)
- Anthony Randolph (Email: acrand@us.ibm.com)
