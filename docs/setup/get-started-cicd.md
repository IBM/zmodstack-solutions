<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->

# Getting Started using CI/CD technologies
 
## Run automation via Travis CI
 - **TODO** - work in progress 
 <!-- NOTES

 - Environment variables:
   - SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS: 
   **Important** this must be created first so it is exported first in Travis OS, to be used in the other env vars!
      ```
       $TRAVIS_BUILD_DIR/zmodstack-solutions/ibm/seaa/ansible
      ```
   - ANSIBLE_FILTER_PLUGINS:
      ```
      $SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS/plugins/filter:~/.ansible/plugins/filter:/usr/share/ansible/plugins/filter
      ```
   - ANSIBLE_LIBRARY:
      ```
      ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/validation:~/.ansible/plugins:/usr/share/ansible/plugins
      ```
    
 - Add [.travis.yml](../.travis.yml) file to root of branch 
 
 - TODO Add SSH Keys??
 - 
  - Configure token for endpoints
   - Add SECRET ENV variable with OCP login token
   - Make sure the following is in inventory file to reference token used to login to OCP cluster
-->
## Run automation via Jenkins
 - **TODO** - work in progress 
 
## Run automation via OpenShift Pipelines
 - **TODO** - work in progress 

---
## Next steps [troubleshooting](../guide/troubleshooting.md) -or- [back to framework guide](../guide/README.md)