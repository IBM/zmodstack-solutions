<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->
# Ansible Variable Files
The following table provides details about variable files used with the Solution Enablement Ansible Automation (SEAA) framework.

<!--# Ansible Config
- sample.ansible.cfg - edited this file, renamed to .ansible.cfg and saved to your home directory or ansible.cfg and save to directory playbook
-->
<table>
<thead>
  <tr>
    <th>Directory</th>
    <th>Variable file</th>
    <th>Description</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="3">config/</td>
    <td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/config/.config">.config</a>     </td>
    <td>SEAA framework configuration/setup</td>
  </tr>
  <tr><td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/config/seaa_config.yaml">seaa_config</a></td>
    <td>Control automation for SEAA framework</td></tr>
	<tr><td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/config/seaa_config.yaml">seaa_trouble</a></td>
    <td>Troubleshooting SEAA framework</td></tr>
<tr>
    <td rowspan="4">defaults/</td>
    <td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/defaults/ocp.yaml">ocp</a>     </td>
    <td>Default variables for Openshift cluster</td>
  </tr>
  <tr><td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/defaults/zoscb.yaml">zoscb</a></td>
    <td>Default variables for z/OS Cloud Broker</td></tr>
	<tr><td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/defaults/zpm.yaml">zpm</a></td>
    <td>Default variables for z/OS Package Manager</td></tr>
	<tr><td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/defaults/zproducts.yaml">zproducts</a></td>
    <td>Default variables for z/OS products being deployed/undeployed</td></tr>
<tr>
	<td>protected/</td>
	<td><a href="https://github.com/IBM/zmodstack-solutions/blob/main/ibm/seaa/ansible/variables/protected/constants.yaml">constants</a></td>
    <td>Constants used by the seaa framework that should not changed</td></tr>
	</tbody>
	</table>

## Ansible Extra-vars
Extra-vars have the highest-level of precedence and can be used to override ANY ansible variables when [running](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#defining-variables-at-runtime) the framework.

- You can provide a default extra-vars file **'[seaa-extra-vars.json](./seaa-extra-vars.json)'** by adding the appropriate json and saving `seaa-extra-vars.json` file to the `SEAA_CONFIG_PATH_TO_SE_VARIABLES` directory, see below:
  ```
  ${SEAA_CONFIG_PATH_TO_SE_VARIABLES}/seaa-extra-vars.json
  ```
  Example:
  ```json
   { "project_names" : "zstack-foo" }

  ```
  **Note** The default `SEAA_CONFIG_PATH_TO_SE_VARIABLES`=[${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/variables](../variables/)
---
## [back to framework guide](../../../../docs/guide/README.md)
