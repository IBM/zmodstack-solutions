# How to get API server for your OCP host
When configuring your [inventory](../../playbooks/inventory/sample-inventory.yaml) file, you will need the API server URL to define the OCP host.
Complete these steps to obtain the API server URL for your OCP cluster.

1. Access the OCP cluster's command-line interface (CLI) or management console.
If you are using the CLI, log in to the cluster by executing the appropriate command, such as oc login.

1. Upon successful login, use the following command to retrieve the API server.
   ```
   oc cluster-info
   ```
    **Sample output:**
   ```
   | => oc cluster-info
    Kubernetes control plane is running at https://api.zstack.ibm.com:6443

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    ```
3. Copy the API server.
  Look for the line that has "api" in URL output. The API server is usually listed next to it, and it typically starts with 'https://api.' in our example:
    ```
    api.zstack.ibm.com
    ```

That's it! You have now found the API server URL for your OCP cluster.
