# Getting Started using CI/CD technologies
 
## Run automation via Travis CI
 - **TODO** - work in progress 
 <!-- NOTES

 - Environment variables:
   - SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS:
      ```
      $TRAVIS_BUILD_DIR/scenarios/ansible
      ```
   - ANSIBLE_FILTER_PLUGINS:
      ```
      $SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS/plugins/filter:~/.ansible/plugins/filter:/usr/share/ansible/plugins/filter
      ```
    # Travis ENV Vars
    # SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS=$TRAVIS_BUILD_DIR/scenarios/ansible
    # ANSIBLE_FILTER_PLUGINS=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/filter:~/.ansible/plugins/filter:/usr/share/ansible/plugins/filter
    # ANSIBLE_LIBRARY=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/plugins/validation:~/.ansible/plugins:/usr/share/ansible/plugins
    
 - Add [.travis.yml](../.travis.yml) file to root of branch 
 - Add SSH Keys to this [directory](../../../zoscb-e2e/ansible_roles/ocp_cluster/secrets)
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
## Next steps [troubleshooting](/zmodstack-solutions/docs/guide/troubleshooting.md) -or- [back to framework guide](/zmodstack-solutions/docs/guide/README.md)