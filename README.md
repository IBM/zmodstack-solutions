# Solutions Enablement for IBM Z and Cloud Modernization Stack
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)

# Overview
This repo contains solutions, automated scenarios and artifacts for deploying and administrating IBM Z and Cloud Modernization Stack resources. The goal is to provide solutions that enhance modernization journey when using the stack.

One way this is achieved is with the Solutions Enablement Ansible Automation (SEAA) framework for IBM Z and Cloud Modernization Stack. The SEAA framework consist of [Ansible Variable](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html), [Ansible Playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html), [Ansible Roles](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html), [run_playbooks](/ibm/seaa/scripts/run_playbooks/README.md) and [admin scripts](/ibm/seaa/scripts/admin/README.md) scripts that allow you to deploy and administer components of the stack. In addition to the SEAA framework this repo provides [persona-based](/docs/scenarios/README.md) samples to achieve the stated goal. See table below for automated solutions that are provided or under consideration. <br>


## Automated Solutions
The table here provides an overview of solutions that are considered for automation.
<table>
<thead>
  <tr>
    <th>Certified Operator</th>
    <th>Automation Solution</th>
    <th>Supported</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="4">IBM z/OS Cloud Broker using <a href="https://www.ibm.com/docs/en/cloud-paks/z-modernization-stack/2023.1?topic=azrpzcb-performing-zos-cloud-broker-tasks-via-kubernetes-native-api-calls" target="_blank" rel="noopener noreferrer">Kubernetes native APIs</a></td>
    <td>Deploy IBM z/OS Package Manager</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM Z Open Automation Utilities</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM Open Enterprise Languages</td>
    <td>:heavy_check_mark:</td>
  </tr>
  <tr>
    <td>Deploy IBM IMS Operator</td>
    <td>WIP</td>
  </tr>
  <tr>
    <td>Wazi DevSpaces</td>
    <td colspan="2">Not automated (under consideration)</td>
  </tr>
  <tr>
    <td>Wazi Sandbox</td>
    <td colspan="2"><ul><li>Not automated (under consideration)</li><li>Secure with RACF Operator - Not automated (under consideration)</li></ul>
</td>
  </tr>
  <tr>
    <td>z/OS Connect EE</td>
    <td colspan="2">Not automated (under consideration)</td>
  </tr>
</tbody>
</table>

## Getting started with solutions
- [Solution Enablement Ansible Automation framework](docs/guide/README.md)
- [Persona-based scenarios](docs/scenarios/README.md)

## How to contribute
Check out the [contributor documentation](CONTRIBUTING.md).

## Copyright
© Copyright IBM Corporation 2023.