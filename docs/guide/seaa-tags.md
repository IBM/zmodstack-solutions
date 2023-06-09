<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->

# Using SEAA tags
The following is a list of 'tags' available for use when running deployment scripts or playbooks.
Tags can be used to deploy/undeploy or skip deployment/undeployment of resources.

## Deploying Open Enterprise Languages development environments-aaS (oel-dev)

### OEL tags
 -  oel-dev - deploy zoscb, zpm and all compilers & languages 
 -  go      - deploy Go
 -  java    - deploy Java
 -  nodejs  - deploy NodeJS
 -  oelcpp - deploy OELCPP
 -  python  - deploy Python
 -  zoau    - deploy ZOAU

### Operator and SubOperator tags
 -  zoscb   - deploy Z/OS Cloud Broker (require if smart deploy is not on)
 -  zpm     - deploy Z/OS Package Manager (require if smart deploy is not on)
  
### Functional tags
 -  developer - deploy developer resources

---
## [back to framework guide](../guide/README.md)
