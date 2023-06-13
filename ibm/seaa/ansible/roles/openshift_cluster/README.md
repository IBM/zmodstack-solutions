<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->
openshift_cluster
=========

This role contains task used to manage resources for openshift used by the seaa framework

Requirements
------------

Openshift cluster v4.9 or later

Role Variables
--------------
**default/main.yml **
  - openshift_host:
  - openshift_cluster_username:
  - openshift_cluster_password:
  - openshift_token:
  - validate_openshift_certs: false
  - openshift_cert:
  - openshift_auth_results:

<!-- A description of the sett able variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.-->
Role Task
--------------
  - authenticate - Authenticate to Openshift cluster
  - manage_secrets - Manage secrets for ssh keys used with IBM Cloud Broker
  - manage_signature - Manage signature files used for IBM Cloud Broker operator collections 
Dependencies
------------

None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:


    - name: Deploy signature file for OC
      ansible.builtin.include_role:
        name: openshift_cluster
        tasks_from: manage_signature
      vars:
        iscleanup: false
License
-------

Apache 2.0

Author Information
------------------

Anthony Randolph - acrand@us.ibm.com
