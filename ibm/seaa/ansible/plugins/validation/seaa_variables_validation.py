#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) IBM Corporation 2023
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import absolute_import, division, print_function

__metaclass__ = type


DOCUMENTATION = r'''
---
module: seaa_variables_validation
short_description: Validate SEAA framework variables
version_added: "0.0.1"
description:
  - This module is used to verify inventories and variable files used with SEAA framework for IBM Z and Cloud Modernization Stack.
  - The validation automatically includes all default variables used with the SEAA framework along with the inventory source specified and any extra-var files provided.
author:
  - "Anthony Randolph (@acrand-ibm)"
options:
    inventory_source:
      description: 
         - Inventory source to be validated. 
         - Can be inventory file, directory or list of inventory files.
       required: true
       type: raw
    schema_path:
       description: Directory path to seaa_schema.yaml file use to validate inventories and variables.
       required: false
       type: path    
    extra_var_files:
       description: List of Ansible extra-var files to be validated used in validation
       required: false
       type: list
'''

RETURN = r'''
msg:
    description: The output message from running validation
    type: str
    returned: always
    sample: "Validation completed successfully"
seaa_schema_file:
    description: The path to the seaa_schema file used to run validation
    type: str
    returned: always
    sample: "/path-to-seaa-schema-file"

'''

EXAMPLES = r'''
- name: Validate single inventory file variables
    seaa_variables_validation:
        inventory_source: "/path-to-inventory-dir/inventory1.yaml"
                
- name: Validate multiple inventory file and extra-vars file variables
    seaa_variables_validation:
        inventory_source:
            - "/path-to-inventory-dir/inventory1.yaml"
            - "/path-to-inventory-dir/inventory2.yaml"
        extra_var_files: 
            - "/path-to-extra-var-dir/extra-var.json"
            
- name: Validate all inventories in a directory and extra-vars file variables
    seaa_variables_validation:
        inventory_source:
            - "/path-to-inventory-dir"
        extra_var_files: 
            - "/path-to-extra-var-dir/extra-var.json"
'''

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.process import get_bin_path
import yaml
import tempfile
import os
import re
import json
import shutil

# NoActiveHost exception class                
class NoActiveHost(Exception):
    pass

# MissingVariable exception class
class MissingVariable(Exception):
    pass

# MissingVariableValue exception class
class MissingVariableValue(Exception):
    pass

# Work directory to use for temp files used to validate variables
seaa_work_dir = "/tmp/.seaa" #os.path.expanduser("~")+'/.seaa/tmp'

# Prefix for tmp files
tmp_file_prefix = "vseaa"

# schema_type = "complex"

# Function to validate inventory and combined ansible variables
def validate_seaa_variables(module, inventory_data: str, schema_data: str):

    # Validate variables for 'ocphosts' groups
    if validate_group_hosts(module, inventory_data, schema_data, 'ocphosts'):
       # Validate variables for 'zosendpoints' groups
       return validate_group_hosts(module, inventory_data, schema_data, 'zosendpoints')
    else:
       return False   
 
# Validate inventory groups
def validate_group_hosts(module, inventory_data: str, schema_data: str, validating_group: str):
    # Variable to track if any host is active
    any_active_host_in_group = False

    # Iterate over groups in the inventory
    for current_group_name, group_data in inventory_data['all']['children'][validating_group]['children'].items():
        
        # Check if 'hosts' fields are in group_data
        if 'hosts' in group_data:
            
            # Iterate hist in group data 
            for host_name, host_variables in group_data['hosts'].items():
                # Check if '_is_active' exist and has a value in this group
                _check_for_active_host(host_name, host_variables, validating_group)

                # Check if '_is_active' is true
                if host_variables['_is_active'] == True:
                    # Set any active host to True
                    any_active_host_in_group = True
                    # Validate current groups host against schema data
                    schema_validation(module, schema_data, validating_group, current_group_name, host_name, host_variables)

    #Fail if none of the hosts are active
    if not any_active_host_in_group:
        raise NoActiveHost(f"Error validating '{validating_group}': None of the hosts are active in inventory. Validation failed.") #NoActiveHost
    else:
        return any_active_host_in_group
    
def _check_for_active_host(host_name, host_variables, validating_group): 
    # Perform testing on host values here
    if '_is_active' not in host_variables:
        raise NoActiveHost(f"Error validating '{validating_group}': '_is_active' is not defined in {host_name}") #NoActiveHost
    elif '_is_active' in host_variables and host_variables['_is_active'] == None:
        raise NoActiveHost(f"Error validating '{validating_group}': '_is_active' has no default value set.") #NoActiveHost

def schema_validation(module, schema_data, validating_group, current_group_name, host_name, host_variables):
    # Get schema type for validation
    _schema_type = module.params['schema_type']

    # Validate host for a specific group
    if _schema_type == "complex":
        validate_host_complex_types(schema_data, validating_group, current_group_name, host_name, host_variables)
    else:    
        validate_host_simple(schema_data, current_group_name, host_name, host_variables)
        
# Validate values for inventory host
def validate_host_complex_types(schema_data: str, validating_group: str, current_group_name: str, host_name: str, host_variables):

    # Iterate of variables in schema
    for variable, variable_schema in schema_data.items():
        # Check if variable is 'all_groups' and continue
        if variable == 'all_groups':
          # Continue to next variable
          continue
        else:  
            # Set variable to check if variable is required
            _is_required = variable_schema['host_group']['required']
            
            # Set variable for group_names to check
            _group_names = variable_schema['host_group']['name']
                
            # Check if parm is required and should be validated against group being validated
            if _is_required and validating_group in _group_names and variable not in host_variables:
                raise MissingVariable(f"Variable '{variable}' is missing for host '{host_name}' in '{current_group_name}' for '{validating_group}'") #MissingVariable
            # Check if group being verified is in list for variable
            elif validating_group in _group_names:

                
                _do_validate_host_complex_types(variable, host_variables[variable], variable_schema, validating_group, current_group_name, host_name)

def _do_validate_host_complex_types(variable, variable_value, variable_schema, validating_group: str, current_group_name: str, host_name: str):

    # Set variable to check if variable is required
    _is_required = variable_schema['host_group']['required']

    # Check if variable value is None
    if _is_required and ( variable_value == None or variable_value == "" ) :
        raise MissingVariableValue(f"Variable '{variable}' value not provided for host '{host_name}' in '{current_group_name}' for '{validating_group}'") #MissingVariableValue
    # Check if the variable is of the correct type
    elif _is_required and isinstance(variable_value, list) and (len(variable_value) == 0 or all(element == None for element in variable_value)):
        raise MissingVariableValue(f"Variable '{variable}' has no values for host '{host_name}' in '{current_group_name}' for '{validating_group}'") #MissingVariableValue
    elif variable_value != None and variable_value != "" : # or (isinstance(variable_value, list) and (len(variable_value) != 0 and all(element != None for element in variable_value))):
            validate_complex_types(host_name, variable_schema['data_type'], variable, variable_value, validating_group, current_group_name)

# Validate data types for variable value
def validate_complex_types(host_name, _expected_types, variable, variable_value, validating_group, current_group_name):
    # Convert expected types to a tuple of types
    if isinstance(_expected_types, str):
        expected_types = (eval(_expected_types),)
    elif isinstance(_expected_types, list):
        expected_types = tuple(eval(t) for t in _expected_types)

    # Check if variable value is expected type
    if not isinstance(variable_value, expected_types):
        if len(expected_types) == 1:
            expected_type_str = expected_types[0].__name__
            raise TypeError(f"Variable '{variable}' for host '{host_name}' in '{current_group_name}' for '{validating_group}' is not of type '{expected_type_str}'") #IncorrectVariableType
        else:
            expected_type_names = [expected_type.__name__ for expected_type in expected_types]
            expected_type_str = " or ".join(expected_type_names)
            raise TypeError(f"Variable '{variable}' for host '{host_name}' in '{current_group_name}' for '{validating_group}' is not one of the expected types: {expected_type_str}") #IncorrectVariableType
    # Check if values in a list are the right type 
    elif isinstance(variable_value, list) and not validate_list_type(variable_value, expected_types):
        raise TypeError(f"Variable '{variable}' value '{variable_value}' for host '{host_name}' in '{current_group_name}' for '{validating_group}' is not the expected type: {expected_types}") #IncorrectVariableType

# Check if values in a list are of the right type 
def validate_list_type(value_list, expected_types):
    # Check if expected type is only 1 type and it is a list
    if len(expected_types) == 1 and expected_types[0] == list:
        return True
    else:  
        # Iterate over values in a list and verify if they are of the expected type  
        for value in value_list:
            if not isinstance(value, expected_types):
                return False
        return True

# Validate values for inventory host
def validate_host_simple(schema_data: str, group_name: str, host_name: str, host_variables):

    # Check if all required variables are present and of the correct type in the host's variables
    for variable, expected_types in schema_data.items():
        if variable not in host_variables:
            raise MissingVariable(f"Variable '{variable}' is missing for host '{host_name}'") #MissingVariable
        else:
            # Set variable value
            variable_value = host_variables[variable]

            # Check if variable value is None
            if variable_value == None or variable_value == "" :
                raise MissingVariableValue(f"Variable '{variable}' value not provided for host '{host_name}' in '{group_name}'") #MissingVariableValue
            # Check if the variable is of the correct type
            elif isinstance(variable_value, list) and (len(variable_value) == 0 or all(element == None for element in variable_value)):
                raise MissingVariableValue(f"Variable '{variable}' has no values for host '{host_name}'") #MissingVariableValue
            else:
                validate_simple_types(host_name, expected_types, variable, variable_value)

# Validate data types for variable value
def validate_simple_types(host_name, expected_types, variable, variable_value):
    # Convert expected types to a tuple of types
    if isinstance(expected_types, str):
        expected_types = (eval(expected_types),)
    elif isinstance(expected_types, list):
        expected_types = tuple(eval(t) for t in expected_types)
    
    # Check if variable value is expected type
    if not isinstance(variable_value, expected_types):
        if len(expected_types) == 1:
            expected_type_str = expected_types[0].__name__
            raise TypeError(f"Variable '{variable}' for host '{host_name}' is not of type '{expected_type_str}'") #IncorrectVariableType
        else:
            expected_type_names = [expected_type.__name__ for expected_type in expected_types]
            expected_type_str = " or ".join(expected_type_names)
            raise TypeError(f"Variable '{variable}' for host '{host_name}' is not one of the expected types: {expected_type_str}") #IncorrectVariableType

# Function to cleanup tmp fille directories
def cleanup_tmp_dir(_temp_dir):
    # Clean the directory _temp_dir if it exist
    if os.path.exists(seaa_work_dir):
        # List all directories in the temporary directory
        subdirs = [entry for entry in os.listdir(_temp_dir) if os.path.isdir(os.path.join(_temp_dir, entry))]

        if subdirs:
            # Iterate over the directories and remove those that start with 'seaa'
            for dir_name in subdirs:
                if dir_name.startswith(tmp_file_prefix):
                    dir_path = os.path.join(_temp_dir, dir_name)
                    shutil.rmtree(dir_path)  

# Remove comments for JSON file
def remove_json_comments(json_str):
    # Remove /* comments */
    json_str = re.sub(r"/\*.*?\*/", "", json_str, flags=re.DOTALL)
    return json_str

# Pre=process json file if necessary
def preprocess_json_file(file_path, temp_dir_path):
    with open(file_path, 'r') as file:
        json_content = file.read()

    # Check if the JSON content contains /* comments */
    if re.search(r"/\*.*?\*/", json_content, flags=re.DOTALL):
        # Remove comments from JSON content
        json_content = remove_json_comments(json_content)
    
        # Create a temporary directory
        _, _temp_file = tempfile.mkstemp(dir=temp_dir_path, suffix="_ev")

        # Write content to tmp file
        with open(_temp_file, 'w') as temp_file:
            temp_file.write(json_content)
            temp_file_path = temp_file.name
        
        # Return path to tmp file
        return temp_file_path

    else:
        # No comments found, return the original file path
        return file_path

# Validate path to seaa variables
def validate_seaa_variable_path():
    # Check if SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS is set
    _seaa_ansible_dir = os.environ.get('SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS')
    if _seaa_ansible_dir is None:
        raise NameError("SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS' environment variable are set.") 
    else:
        # Check if SEAA_CONFIG_PATH_TO_SE_VARIABLES variable is set and use it to set seaa_variable_path
        envvar = os.environ.get('SEAA_CONFIG_PATH_TO_SE_VARIABLES')
        if envvar is not None:
          _seaa_variable_path = envvar
        else:
          _seaa_variable_path = _seaa_ansible_dir+'/variables'
    return _seaa_variable_path

# Build ansible-inventory command
def build_ansible_inventory_command(inventory_source, seaa_variable_path, temp_dir_path, temp_file_path, extra_var_files):
    # Get the path to the ansible-inventory command
    ansible_inventory_cmd = get_bin_path('ansible-inventory', required=True)

    # Build the ansible-inventory command with the desired options
    # Create command array for inventory command
    command = []
    
    # Check if inventory source is a list
    if isinstance(inventory_source, list):
        # If source is a list of files
        for file in inventory_source:
            command += [ansible_inventory_cmd, '-i', file]
        # Add output, list and yaml to command
        command += ['--output', temp_file_path, '--list', '--yaml']
    # Else check if inventory source is a single file of directory of inventories
    elif os.path.isfile(inventory_source) or os.path.isdir(inventory_source):
        command = [ansible_inventory_cmd, '-i', inventory_source, '--output', temp_file_path, '--list', '--yaml']
    # Raise error file for directory not found 
    else:
        raise FileNotFoundError(f"Unable to find inventory source '{inventory_source}'")

    # Add seaa config an protected ansible variables as extra-var files
    command += ['-e', '@'+seaa_variable_path+'/config/seaa_config.yaml']
    command += ['-e', '@'+seaa_variable_path+'/protected/constants.yaml']

    # Add seaa default variable files as extra-var files
    for filename in os.listdir(seaa_variable_path+'/defaults'):
        if os.path.isfile(os.path.join(seaa_variable_path+'/defaults', filename)):
            # Add file as extra-var file
            command += ['-e', '@'+seaa_variable_path+'/defaults/'+filename ]

    # Check If 'SEAA_EXTRA_VARS' environment variable exist (created when running - run-playbook scripts)
    extra_vars_env = os.environ.get('SEAA_EXTRA_VARS')
    if extra_vars_env is not None:
        # Add content from SEAA_EXTRA_VARS as extra-vars
        command += ['-e', extra_vars_env]

    # Check any extra_var_files passed into this module and add to command 
    if extra_var_files is not None:
        # Iterate over list of extra vars provided
        for ev_file in extra_var_files:
            # Add file as extra-var file
            command += ['-e', '@'+preprocess_json_file(ev_file, temp_dir_path)]
    return command
 
# Function to build and run the 'ansible-inventory' command
def run_ansible_inventory(module, inventory_source, seaa_variable_path, extra_var_files, _debug):
    
    # Create the directory for temp_dirs if it doesn't exist
    if not os.path.exists(seaa_work_dir):
        os.makedirs(seaa_work_dir)

    # Create tmp dir
    # Get Permission error on Travis with tempfile.TemporaryDirectory(dir=seaa_work_dir) as temp_dir_path:
    temp_dir_path = tempfile.mkdtemp(dir=seaa_work_dir, prefix=tmp_file_prefix)

    # Create a temporary file to store the output
    with tempfile.NamedTemporaryFile(dir=temp_dir_path, delete=False, suffix="_inv") as temp_file:
        # Set path to temp file
        temp_file_path = temp_file.name

        # Build command
        command = build_ansible_inventory_command(inventory_source, seaa_variable_path, temp_dir_path, temp_file_path, extra_var_files)

        # Debug with raise Exception(command)    

        # Run the 'final' ansible-inventory command. 
        # '_' variable would/could set to 'stdout' if used, not used in this case
        rc, _, stderr = module.run_command(command, check_rc=True, encoding=None)
     
        # Check the return code
        if rc != 0:
            module.fail_json(msg=f"ansible-inventory command failed with return code: {rc}, stderr: {stderr}")

        # Parse the inventory output as YAML
        try:
            with open(temp_file_path, "r") as stream:
                inventory_data = yaml.safe_load(stream)
        except ValueError as e:
            module.fail_json(msg=f"Failed to parse ansible-inventory output as YAML: {e}")
        
        # Clean up the temporary file
        if not _debug:
          os.remove(temp_file_path)
    
    # Clean up the temporary directory
    if not _debug:
      shutil.rmtree(temp_dir_path)

    return temp_file_path, inventory_data, command

# Return failure
def return_failure(module, inventory_source, validation_details, e, _debug, _temp_file_path ):

    if not _debug:               
    
        # Return fail_json    
        module.fail_json(msg=f"Failed to validate seaa variable for inventory_source {inventory_source}: {str(e)}",
                        validation_info=validation_details)
    else: # Debug is True
        # Return fail_json    
        module.fail_json(msg=f"Failed to validate seaa variable for inventory_source {inventory_source}: {str(e)}",
                        validation_info=validation_details,
                        validation_debug_info=_temp_file_path
                        )

# Return results
def return_results(module, result, _debug, _temp_file_path):
    if not _debug:
        # simple AnsibleModule.exit_json(), passing the key/value results
        module.exit_json(**result)
    else:
        module.exit_json(**result,
                validation_debug_info=_temp_file_path)

# Validate if list is empty bracket '[]'         
def is_list_field_empty(field_data):
    if isinstance(field_data, list) :
       return field_data == []
    return False

# Function to run Ansible Module       
def run_module():

    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        inventory_source=dict(type='raw', required=True),
        schema_path=dict(type='path', required=False),
        extra_var_files=dict(type='list', required=False),
        debug=dict(type='bool', required=False, default=False),
        schema_type=dict(type='str', required=False, default='complex', choices=['complex', 'simple'])
    )

    # define the result dictionary return any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        msg='',
        seaa_schema_file=''
    )

    # define module as the AnsibleModule object will be our abstraction working with Ansible
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )
 
    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # **********************************************  
    # Start custom module state and implementation
    # **********************************************  
    # Set debug param
    _debug = module.params['debug']

    # Check if should cleanup 
    if not _debug:
      cleanup_tmp_dir(seaa_work_dir)
    
    # Path to SEAA variables used for validating ansible variables used with inventory
    seaa_variable_path = ""

    # Define inventory_source variable
    inventory_source = ""
    
    # Try set path to seaa variables
    try:
        # Get path to seaa variables 
        seaa_variable_path = validate_seaa_variable_path()
    except Exception as e:  
        module.fail_json(msg="Failed validating path to SEAA variables: {}".format(str(e)))

    # Try run 'ansible-inventory' command    
    try:
        # Run ansible-inventory command for inventory_sources
        inventory_source = module.params['inventory_source']
        extra_var_files = module.params['extra_var_files']

        _temp_file_path, inventory_data, _command = run_ansible_inventory(module, inventory_source, seaa_variable_path, extra_var_files, _debug)
    except Exception as e:  
        module.fail_json(msg=f"Failed to process Inventory source '{inventory_source}': {str(e)}")

    # Try load 'seaa_schema.yaml' file for validating variable schema data
    try:
        # Load seaa variable schema    
        schema_path = module.params['schema_path']
        
        # Check if schema parameter if provided
        if schema_path == None:
            # Get schema type for validation
            _schema_type = module.params['schema_type']
            
            if _schema_type == "complex":
                # Set schema to complex schema file   
                schema_path = seaa_variable_path+'/protected/seaa_schema.yaml'
            else: 
                # Set schema to simple schema file  
                schema_path = seaa_variable_path+'/protected/seaa_schema_simple.yaml'
            
        # Open and load schema data file
        with open(schema_path, 'r') as schema_file:
          schema_data = yaml.safe_load(schema_file)

        # Add the path to the schema file used for validation    
        result['seaa_schema_file'] = schema_path
    except Exception as e:
        module.fail_json(msg=f"Failed to process YAML file '{schema_path}': {str(e)}")

    # Try validating inventory data against variable schema data
    try:
        # Validate inventory and ansible variables
        if validate_seaa_variables(module, inventory_data, schema_data):
          # Return successful results
          result['msg']="Validation completed successfully"
    except Exception as e:
        # Check if ansible verbosity is greater or equal to 3
        if module._verbosity == 3:
            
            # Check If 'SEAA_EXTRA_VARS' environment variable exist (created when running - run-playbook scripts)
            extra_vars_env = os.environ.get('SEAA_EXTRA_VARS')

            # Add SEAA_EXTRA_VARS if it exist to fail_json output
            if extra_vars_env is not None:
                validation_details = {
                        "details": "Verify the files and environment variable 'SEAA_EXTRA_VARS' used for validation",
                        "validation_files": {
                                "seaa_ansible_variable_path": seaa_variable_path,
                                "extra_var_files": extra_var_files,
                                "seaa_schema_file": schema_path
                            },
                         "validation_seaa_extra_vars": extra_vars_env
                        }
            else: # Build details for fail_json
                validation_details = {
                            "details": "Verify the files used for validation",
                            "validation_files": {
                                    "seaa_ansible_variable_path": seaa_variable_path,
                                    "extra_var_files": extra_var_files,
                                    "seaa_schema_file": schema_path
                                }
                            }
            
            # Return failure
            return_failure(module, inventory_source, validation_details, e, _debug, _temp_file_path)            
      
        elif module._verbosity == 4: # Check if ansible verbosity is greater or equal to 3
        
            # Check If 'SEAA_EXTRA_VARS' environment variable exist (created when running - run-playbook scripts)
            extra_vars_env = os.environ.get('SEAA_EXTRA_VARS')

            # Add SEAA_EXTRA_VARS if it exist to fail_json output
            if extra_vars_env is not None:
                validation_details = {
                        "details": "Verify the files and environment variable 'SEAA_EXTRA_VARS' used for validation",
                        "validation_files": {
                                "seaa_ansible_variable_path": seaa_variable_path,
                                "extra_var_files": extra_var_files,
                                "seaa_schema_file": schema_path,
                                "inventory_command": _command
                            },
                         "validation_seaa_extra_vars": extra_vars_env
                        }
            else: # Build details for fail_json
                validation_details = {
                            "details": "Verify the files used for validation",
                            "validation_files": {
                                    "seaa_ansible_variable_path": seaa_variable_path,
                                    "extra_var_files": extra_var_files,
                                    "seaa_schema_file": schema_path,
                                    "inventory_command": _command
                                }
                            }

            # Return failure
            return_failure(module, inventory_source, validation_details, e, _debug, _temp_file_path)            
        else:    
            # Return fail_json  
            module.fail_json(msg=f"Failed to validate seaa variable for source {inventory_source}: {str(e)}")

    # **********************************************  
    # End custom module state and implementation
    # **********************************************  
    return_results(module, result, _debug, _temp_file_path)
        
def main():
    run_module()

if __name__ == '__main__':
    main()

#***************************************