# Troubleshooting
## SEAA variable validation error
 - The framework provides a module to validate the inventory and variables used at runtime. If an error message occurs review and make the necessary updates to the inventory or variable files as required.
  
## Known local run errors
 - ERROR! Unknown error when attempting to call Galaxy at 'https://galaxy.ansible.com/api/': <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed
   <img width="702" alt="image" src="https://media.github.ibm.com/user/55799/files/f28e60b0-7485-43ba-b2a6-6152780f6236">

 - ERROR! A worker was found in a dead [state](https://stackoverflow.com/questions/50168647/multiprocessing-causes-python-to-crash-and-gives-an-error-may-have-been-in-progr):
    ```
    export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
    ```
     <!-- adding dns and ip and /etc/hosts --> 

---
## [back to framework guide](/docs/guide/README.md)