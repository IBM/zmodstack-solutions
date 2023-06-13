#
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#

# Getting Started Workstation

**Clone the ['zmodstack-solutions'](https://github.com/IBM/zmodstack-solutions) repo and follow the steps below to setup your workstation.**

---

## Install Python and Homebrew packages
- [Python 3.8](https://www.python.org/downloads/) or later
- Python Packages:
  - [Ansible 6.3.0 or later](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) - ex: `python -m pip install ansible`
  - [Ansible Lint 5.2.1 or later](https://ansible-lint.readthedocs.io/en/latest/installing.html#using-pip-or-pipx) - ex: `python -m pip install ansible-lint`
  - [Kubernetes 23.3.0 or later](https://pypi.org/project/kubernetes/) - ex: `python -m pip install kubernetes`
  - [Jmespath 1.0.1 or later](https://pypi.org/project/jmespath/) - ex: `python -m pip install jmespath`
  - [Requests-OAuthlib 1.3.1 or later](https://github.com/requests/requests-oauthlib) - ex: `python -m pip install requests-oauthlib`
  - [yq 4.9 or later](https://github.com/mikefarah/yq) - ex: `python -m pip install yq` or for Mac M1 chip `brew install yq`
  - [jq 1.6 or later](https://stedolan.github.io/jq/) - ex: `python -m pip install jq`  or for Mac M1 chip `brew install jq`
---
## Install openshift-client 'oc' from Openshift cluster
- Login to cluster locate 'Command line tools' in <img width="43" alt="image" src="https://media.github.ibm.com/user/55799/files/cafe4e8b-be3c-42aa-a5a8-f3728c0167c9"> menu option: <br>
	  <img width="284" alt="image" src="https://media.github.ibm.com/user/55799/files/0a1226ec-7940-401b-988b-4736f6fcfb19">

- Download appropiate 'oc' CLI for your workstation: <br>
	  <img width="863" alt="image" src="https://media.github.ibm.com/user/55799/files/3d88341b-9ea3-4e43-af0d-c09146fed8a1">

- Extract and place 'oc' executable on your systems PATH:
    ```
    sudo mv <extracted_to_dir>/oc /usr/local/bin
    ```

- Verify 'oc' is installed 
    ```
    oc version
    ```

  **Note: It maybe necessary to "Allow" the 'oc' executable to run on MacOs:** <br>
---	
## Install 'zoscb-encrypt' binary
  - See installation [instructions](https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/2023.1?topic=credentials-installing-zoscb-encrypt-cli-tool) 
  - Verify 'zoscb-encrypt CLI tool' is installed and accept license agreement
    ```
    zoscb-encrypt version
    ```
    <img width="1107" alt="image" src="https://media.github.ibm.com/user/55799/files/dff4f584-0ba9-4569-addb-8b2c59e5535f">
---   
## (Optional) Install [1Password](https://1password.com/developers) CLI [tools](https://developer.1password.com/docs/cli/get-started#requirements) for integration with framework.
   - See [password_vault](../../ibm/seaa/ansible/roles/password_vault/README.md) role for more information.

---
## Next steps [configure workstation](../guide/configure-seaa.md) -or- [back to framework guide](../guide/README.md)
