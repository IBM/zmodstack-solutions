<!-- #
# Copyright 2023 IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
# -->

# Scenario A - Admin Deployment of z/OS artifacts

## Description:
OCP Admin Zach deploys ZOSCB,  ZPM(OSI) and ZOAU(OSI) as requested by early tenure z/OS Application developer Deb using his SHARED RACF credentials for the z/OS endpoint.

## Systems:

- One OCP Host (single admin namespace for Sys Admin)

- One z/OS Endpoint for z/OS Sys Prog

- **Suggested Use-cases:** Test System

## Personas:

Zach - Sys Admin (Senior z/OS Systems Programmer)

Deb - Developer (Early tenure z/OS Application) - needs ZOAU

## Scenario Steps:

- Pre-Req - Create or Discover the z/OS ID used by Zach on the target z/OS Endpoint that have the required RACF Credentials/USS permissions to install software

- Zach (Sys Admin) - Deploy Admin Project and Broker to OCP

- Zach (Sys Admin) - Deploy ZPM and ZOAU Operators with SHARED Credentials to OCP

- Zach (Sys Admin) - Install an instance of ZPM and ZOAU on OCP and z/OS endpoint

- Deb (Developer) - Configures and uses ZOAU on the z/OS endpoint

## Component Topology Post Install:

**OCP Cluster (s390x)** →

- Admin Namespace → z/OS Cloud Broker → Installed by Zach (Sys Admin) →

  - ZPM OC → ZPM Sub-OC (SHARED) → z/OS Endpoint CR → ZPM Instance

  - ZOAU OC → ZOAU Sub-OC (SHARED) → z/OS Endpoint CR → ZOAU Instance

**z/OS Endpoint (Wazi-Sandbox)** →

- ZPM Instance (Installed by ZPM Sub-OC with Zach’s (Sys Admin) SHARED Credentials)

- ZOAU Instance (Installed by ZOAU Sub-OC with Zach’s (Sys Admin) SHARED Credentials)

