zos_dev_envs
=========

This role creates a z/OS development environment resources using IBM Z and Cloud Modernization Stack

Requirements
------------
OpenShift cluster 4.9 our later with entitlement keys for IBM Z and Cloud Modernization Stack components. This role uses the 'zoscb_e2e' collection of roles; the 'openshift_cluster', 'password_vault' roles to deploy resources.

Role Variables and directory information
--------------

<!-- 
A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well. -->

<table>
<thead>
  <tr>
    <th>File name</th>
    <th>Variable</th>
    <th>Description</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="2">defaults/main.yml</td>
    <td>namespace_names</td>
    <td>Array of namespaces</td>
  </tr>
  <tr><td>zpm_install_dir_prefix</td>
    <td>Writable prefix on USS directory z/OS Endpoint for z/OS Package Manager to install z/OS products</td></tr>
	</tbody>
 	</table>
  </html>
  <table>
  <thead>
  <tr>
    <th>File name</th>
    <th>Directory</th>
    <th>Description</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="3">dvars/main.yml</td>
    <td>zoscb_e2e_roles_directory</td>
    <td>z/OS Cloud Broker E2E role directory</td>
  </tr>
  <tr><td>zoscb_e2e_task_directory</td>
    <td>z/OS Cloud Broker E2E task parent directory</td></tr>
  <tr><td>ocp_task_dir</td>
    <td>OCP task directory</td></tr>
	</tbody>
	</table>

<!--   
defaults/main.yml
  - namespace_names - Array of namespaces
  - zpm_install_dir_prefix - Writable prefix on USS directory z/OS Endpoint for ZPM to install zproducts
  
vars/main.yml

- zoscb_e2e_roles_directory - **ZOS Broker E2E role directory**
- zoscb_e2e_task_directory - **ZOS Broker E2E task parent directory**
- ocp_task_dir - **OCP task directory** -->

**zOpen Enterprise Languages Task directories**
- go_cr_task_dir
- java_cr_task_dir
- nodejs_cr_task_dir
- oelcpp_cr_task_dir
- python_cr_task_dir
- zoau_cr_task_dir
- zpm_cr_task_dir

**zOpen Tools Task directories**
- make_cr_task_dir

**Variable to check if endpoint variables have been loaded**
- endpoint_vars_loaded: false

**Variable to check if ocp_cluster variables have been loaded**
- ocp_cluster_vars_loaded: false

**Variables to check if zProduct variables have been loaded**
- go_vars_loaded: false
- java_vars_loaded: false
- make_vars_loaded: false
- nodejs_vars_loaded: false
- oelcpp_vars_loaded: false
- python_vars_loaded: false
- zoau_vars_loaded: false
- zpm_vars_loaded: false

**Variables for SubOperator domain loaded**
- subop_vars_loaded: false

**Name of the project used in the current project iteration**
- this_project_name:

**In mem cache for automation status**
- ocp_cluster_cache:

**Flag to determine if Broker is deployed**
- zoscb_deployed: false

**Flag to determine if ZPM is deployed**
- zpm_deployed: false


<!-- group_vars:

host_vars: -->


Dependencies
------------
- zoscb_e2e - collection of roles
- openshift_cluster - role
- password_vault (optional) - role

Example Playbook
----------------

License
-------

Apache 2.0

Author Information
------------------

Anthony Randolph - acrand@us.ibm.com
