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
<!-- - config/
	- [.config](config/.config) - SEAA framework configuration/setup
	- [seaa_config](config/seaa_config.yaml) - Control automation for SEAA framework
	- [seaa_trouble](config/seaa_trouble.yaml) - Troubleshooting SEAA framework -->

<!-- - defaults/
	- [ocp](defaults/ocp.yaml) - Default variables for Openshift cluster

	- [zoscb](defaults/zoscb.yaml) - Default variables for z cloud broker

	- [zpm](defaults/zpm.yaml) - Default variables for zos package manager

	- [zproducts](defaults/zproducts.yaml) - Default variables for zos products being deployed/undeployed -->

<!-- - protected/
	- [constants](protected/constants.yaml) - Constants used by the seaa framework that should not changed -->

## Ansible Extra-vars
Extra-vars have the highest-level of precedence and can be used to override ANY ansible variables when [running](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#defining-variables-at-runtime) the framework.

---
## [back to framework guide](/docs/guide/README.md)
