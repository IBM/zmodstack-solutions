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

import os

debugon = False

class FilterModule(object):
    def filters(self):
        return {
            '_debug': self._debug,
            "_prepend_forward_slash": self._prepend_forward_slash,
            '_process_script_update': self._process_script_update,
            '_process_readme_update': self._process_readme_update,
            'append_host_and_namespace_dir': self.append_host_and_namespace_dir,
            'append_prepend_str_if_not_null': self.append_prepend_str_if_not_null,
            'append_str_if_not_null': self.append_str_if_not_null,
            'get_expanded_dir': self.get_expanded_dir,
            'get_relative_dir': self.get_relative_dir,
            'get_simple_version_string': self.get_simple_version_string,
            'get_user_from_cache': self.get_user_from_cache,
            'get_vmp_string': self.get_vmp_string,
            'prepend_str_if_not_null': self.prepend_str_if_not_null,
            'trim_and_strip_firstchar': self.trim_and_strip_firstchar,
            'update_seaa_automation_cache': self.update_seaa_automation_cache,
            'update_cache_for_generating_files': self.update_cache_for_generating_files
        }

    def _debug(self, str):
       if debugon == True:
          print(str)

    def get_user_from_cache (self, cache, host_id):
        # Variable to return with cached username
        cached_username = ''

        # Get cached data array from dictionary
        data = cache['cached']
        self._debug("**** Get User from Cache ****")
        self._debug(data)
        self._debug(host_id)
        # Iterate cached host
        for cached_host in data:
          self._debug(cached_host)
          self._debug(cached_host['ocp_host'])
          # Check if host maches host id to be updated
          if cached_host['ocp_host'] == host_id:
            self._debug("FOUND HOST in cache")
            cached_username = cached_host['username']
            # Exit loop
            break

        # Add cached array back to cache dictionary
        self._debug("Found user: "+ cached_username)
        return cached_username

    def update_seaa_automation_cache (self, cache, host_id, item_to_add, _type):
        self._debug("Enter: update_seaa_automation_cache")

        self._debug("cache: ")
        self._debug(cache)
        self._debug("host_id: ")
        self._debug(host_id)
        self._debug("item_to_add: ")
        self._debug(item_to_add)
        self._debug("_type: ")
        self._debug(_type)

        return_dict = None

        if cache is not None:
          # Get cached data array from dictionary
          data = cache['cached']
          self._debug("**** Update Cache ****")
          self._debug(data)
          self._debug(host_id)
          self._debug(item_to_add)
          self._debug(_type)
          # Iterate cached host
          for cached_host in data:
            self._debug(cached_host)
            self._debug(cached_host['ocp_host'])
            # Check if host maches host id to be updated
            if cached_host['ocp_host'] == host_id:
              self._debug("FOUND HOST TO UPDATE")
              # If Broker
              if _type == 'zoscb':
                # Set array of namespaces broker is verified deployed on
                zoscb_deployed_arr = cached_host['zoscb_deployed_on']
                self._debug(zoscb_deployed_arr)
                # Append new namespace
                zoscb_deployed_arr.append(item_to_add)
                self._debug(zoscb_deployed_arr)
                # Set new array list for cache
                cached_host['zoscb_deployed_on'] = zoscb_deployed_arr
                self._debug("UPDATED HOST: ")
                self._debug(cached_host)
                # Exit loop
                break

              # If ZPM
              if _type == 'zpm':
                # Set array of namespaces zpm is verified deployed on
                zpm_deployed_arr = cached_host['zpm_deployed_on']
                self._debug(zpm_deployed_arr)
                # Append new namespace
                zpm_deployed_arr.append(item_to_add)
                self._debug(zpm_deployed_arr)
                # Set new array list for cache
                cached_host['zpm_deployed_on'] = zpm_deployed_arr
                self._debug("UPDATED ZPM on HOST: ")
                self._debug(cached_host)
                # Exit loop
                break

          # Add cached array back to cache dictionary
          return_dict = { "cached" : data}
          self._debug(return_dict)
        return return_dict

    # Process script update
    def _process_script_update (self, namespace, cached_host):
        # Set array of namespaces gen has started on
        script_gen_arr = cached_host['started_script_gen_on']
        self._debug(script_gen_arr)

        # Get count of namespace in list
        count_item = script_gen_arr.count(namespace)

        # If namespace does exist append to list
        if count_item == 0:
          script_gen_arr.append(namespace)
        else:
          self._debug(namespace+" already exist")

        # Debug script Array
        self._debug(script_gen_arr)
        # Set new array list for cache
        cached_host['started_script_gen_on'] = script_gen_arr
        self._debug("UPDATED cache for host: ")
        self._debug(cached_host)

        return cached_host
    
    # Process readme update
    def _process_readme_update (self, namespace, readme_step_count, cached_host):
        # Initialize flag for finding existing key in cache
        found_key = False
        
        # Set array of namespaces gen has started on
        readme_gen_arr = cached_host['started_readme_gen_on']
        self._debug(readme_gen_arr)

        # Iterate started readme's
        for readme in readme_gen_arr:
          # Check if namespace is a key in readme array
          if namespace in readme.keys():
            # Update reame count
            readme[namespace] = readme_step_count
            # Found existing key
            found_key = True
            # Break inner loop
            break

        if found_key != True:
          # Create namespace field to append to array
          namespace_fld = {}
          namespace_fld[namespace] = readme_step_count
          self._debug(namespace_fld)

          # Append new namespace
          readme_gen_arr.append(namespace_fld)

        # Debug readme Array
        self._debug(readme_gen_arr)

        # Set new array list for cache
        cached_host['started_readme_gen_on'] = readme_gen_arr
        self._debug("UPDATED cache for host: ")
        self._debug(cached_host)

        return cached_host
    

    # Update cache for files being generated
    def update_cache_for_generating_files (self, cache, host_id, namespace, readme_step_count, genfile_type):
        self._debug("Enter: update_cache_for_generating_files")

        self._debug("cache: ")
        self._debug(cache)
        self._debug("host_id: ")
        self._debug(host_id)
        self._debug("namespace: ")
        self._debug(namespace)
        # If Readme
        if genfile_type == 'readme_has_started':
          self._debug("readme_step_count: ")
          self._debug(readme_step_count)

        self._debug("genfile_type: ")
        self._debug(genfile_type)

        # Initialize dict for returning cache
        return_dict = None

        if cache is not None:
          # Get cached data array from dictionary
          data = cache['cached']
          self._debug("**** Update Cache ****")
          self._debug(data)
          self._debug(host_id)

          # Iterate cached host
          for cached_host in data:
            self._debug(cached_host)
            self._debug(cached_host['ocp_host'])

            # Check if host matches host id to be updated
            if cached_host['ocp_host'] == host_id:
              self._debug("FOUND HOST TO UPDATE")

              # If Script
              if genfile_type == 'script_has_started':

                # Process script file updates
                cached_host = self._process_script_update(namespace, cached_host)

                # Exit loop
                break

              # If Readme
              if genfile_type == 'readme_has_started':
                # Process readme file update
                cached_host = self._process_readme_update(namespace, readme_step_count, cached_host)

                # Exit loop
                break

          # Add cached array back to cache dictionary
          return_dict = { "cached" : data}
          self._debug(return_dict)
        return return_dict

    def trim_and_strip_firstchar(self, a_string):
        a_string = a_string.strip()

        if a_string.startswith(","):
          a_string = a_string[1:]

        if a_string.endswith(","):
          a_string = a_string[:-1]

        return a_string

    def append_str_if_not_null(self, a_string, string_to_append):
        return_str = None
        if a_string is not None:
          return_str = a_string + string_to_append
        return return_str

    def prepend_str_if_not_null(self, a_string, string_to_prepend):
        return_str = None
        if a_string is not None:
          return_str = string_to_prepend + a_string
        return return_str

    def append_prepend_str_if_not_null(self, a_string, string_to_prepend, string_to_append):
        return_str = None
        if a_string is not None:
          return_str = string_to_prepend + a_string + string_to_append
        return return_str

    def _prepend_forward_slash(self, _str):
       if _str.startswith("/"):
          return _str
       else:
          return "/" + _str   
       
    # Append Namespace to directory name organized by host of namespace
    def append_host_and_namespace_dir(self, prefix, ocp_host, namespace_delm, default_namespace, zpm_directory_org_by):

        self._debug("Enter: append_host_and_namespace_dir")

        self._debug("prefix: ")
        self._debug(prefix)
        self._debug("default_namespace: ")
        self._debug(default_namespace)
        self._debug("namespace_delm: ")
        self._debug(namespace_delm)
        self._debug("ocp_host: ")
        self._debug(ocp_host)

        if prefix is None:
          return_str = None
        else:
          # Set prefix for return string 
          return_str = prefix
          self._debug("Initial return_str: "+ return_str)

          if default_namespace is not None:
            if zpm_directory_org_by == 'namespace':      
              return_str += self._prepend_forward_slash(default_namespace) + namespace_delm + ocp_host
            else:
              return_str += self._prepend_forward_slash(ocp_host) + namespace_delm + default_namespace

        self._debug("return_str: ")
        self._debug(return_str)
        return return_str

    def get_expanded_dir(self, path):
      return os.path.expanduser(path)

    def get_vmp_string(self, vmp_num):
      tmp_vmp_arr = vmp_num.split('.', 2)


      # Check for non GA version extension - for example 1.0.2-beta.10 - write as "1.0.2-beta-10"
      index_of_dash = tmp_vmp_arr[2].find('-')

      if index_of_dash > 0:
        return  "v"+ tmp_vmp_arr[0] +"minor" + tmp_vmp_arr[1]+ "patch" + tmp_vmp_arr[2].replace('.','-')
      else:
        return  "v"+ tmp_vmp_arr[0] +"minor" + tmp_vmp_arr[1]+ "patch" + tmp_vmp_arr[2]

    def get_relative_dir(self, path, workdir):
      self._debug("Enter: get_relative_dir")
      self._debug("PATH: " + path)
      self._debug("WRKDIR: "+ workdir)

      return os.path.relpath(path, workdir)

    def get_simple_version_string(self, z_product, vmp_num, should_append_version):
      self._debug(z_product+ " - Version Number: " + vmp_num)
      self._debug("Should append version number: " + str(should_append_version))

      if should_append_version == True :
        tmp_vmp_arr = vmp_num.split('.',3)
        return  z_product + '-' +tmp_vmp_arr[0] + tmp_vmp_arr[1] + tmp_vmp_arr[2] + tmp_vmp_arr[3]
      else:
          return z_product
