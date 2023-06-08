password_vault
=========

This role retrieves items from 1password

Requirements
------------

Setup 1password CLI integration.

Role Variables
--------------
### defaults/main.yml
  - **Name of the password vault item**<br>
    item_name:

  - **Flag that specifies if item is a login type**<br>
    is_login_type_item:

Dependencies
------------
None

Usage
----------------
To use this with the SEAA framework make sure the 1password credential item name matches the value of "seaa_security_password_vault_item" variable (default - 'se-login'). This variable is located in 
&lt;seaa_ansible_directory&gt;/variables/config/seaa_config.yaml [file](../../variables/config/seaa_config.yaml).

Here is an example of how this role is used:
```
  - name: Get Item from Password Vault
    ansible.builtin.include_role:
      name: password_vault
      tasks_from: get_1password_creds
    vars:
      item_name: "{{ seaa_security_password_vault_item }}"
      is_login_type_item: true
```
License
-------

Apache 2.0

Author Information
------------------

Anthony Randolph - acrand@us.ibm.com
