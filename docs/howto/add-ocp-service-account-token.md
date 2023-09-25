# Adding OpenShift Service Account Token

- Pre-reqs:
  - OpenShift Cluster Admin user id required
  - Install OpenShift CLI <br>

- Step 1: Create Service Account for SEAA framework<br>
    See below example in the default namespace named: 'seaa-pipeline'
    ```
    $ oc create sa seaa-pipeline -n default
    $ oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:default:seaa-pipeline
    ```
- Step 2: Copy token from OpenShift Service Account<br>
    Example copy 'seaa-pipeline' token
    ```
    <IMAGES>
    ```

- Step 3: Test login with Service Account token (optional)<br>
    ```
    $ oc logout
    $ curl -k -H "Authorization: Bearer <token-from-seaa-pipeline>" <ocp-server>
    ```

- Step 4: Using Service Account in SEAA framwework from workstation
    - Export envfrionment variable:
      ```
      export OCPHOST_AUTHTOKEN=<token-from-seaa-pipeline>
      ```
    - Update inventory to use ENVVAR
      ```
      
      ```      
  