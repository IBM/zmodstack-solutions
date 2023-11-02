# Using Encryption and Secrets to Secure Automation

<!-- Instructions on creating Ansible password files for automation -->

## Create a Vault-Key File
<!-- ### Using File -->
- Create Vault-Key file with a strong vault password, example with OPENSSL
  ```
  openssl rand -out ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault.key -hex 32
  ```
- (Optional-Recommended) Encrypt Vault-Key file with passphrase <br/>
  Note: Enter passphrase when prompted, make sure to store passphrase in a secure location (password vault)
  ```
  openssl enc -aes-256-cbc -salt -in ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault.key -out ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key
  ```
- (Optional) remove unencrypted Vault-Key file
  ```
  rm ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault.key
  ```

- Store this encrypted Vault-Key file in a protected location with access controls,treating it as a master password. 
<!-- To protected file make sure it is NOT shared in any source control management system. -->

- How to recovering Vault-Key file with saved passphrase
  ```
  openssl enc -d -aes-256-cbc -in ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key -out ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_recovered.key 

  You will be prompted for passphrase used to encrypt Vault-Key file
  ```

<!-- ### Using 1Password (WIP)
- Create password item in 1Password vault, note 1Password item name -->
<!-- ### Using ENV?? -->
# Use Encrypted Strings

## Use Vault-Key file to Create Encrypted Ansible Variables
  Run the following command: <br/>
  `ansible-vault encrypt_string <your_secret_string> --name <variable_name> --vault-password-file </path/to/vault_key_file>`
  ```
  ansible-vault encrypt_string '_SECRET_PASSWORD_' --name password --vault-password-file ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key
  ```
  - Copy output and put in variable file
  ```
  password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          34653862353661363064393338666431316563616232646533663138303031323365313666613634
          3132616530613830383364396237323763643664623465360a336239386234373236353065383037
          36313835633534313137383565393535626463616332343065333130396363626536316632323439
          3739376364653737390a333530653761376239623964323538343666386235636463303338666239
          66353837313439636337646130383636383232313734323163383463663333383337326330313935
          6137383766633434346631353763623230633735326266326364
  ```  
# Use Encrypted Files
## Use Vault-Key file to Create Encrypted Registry Password Files
  Run the following command: <br/>
  `ansible-vault create <encrypted_password_file> --vault-password-file </path/to/vault_key_file>`
  - Enter plain text for password when prompted (Save file and exit. On MacOS Control-X->Y->Enter)

  ```
  ansible-vault create ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/zpmtest_registry_password.vault --vault-password-file ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key 
  ```
- Make encrypted file readable on filesystem
  ```
  chmod 655 ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/zpmtest_registry_password.vault
  ``` 

##  Use Vault-Key file to Create Encrypted SSHKey and Passphrase
  Run the following command to create encrypted SSHKey file: <br/>
  `ansible-vault encrypt <sshkey_file> --vault-password-file  </path/to/vault_key_file> --output <target_location_for_encrypted_file>`
  ```
  ansible-vault encrypt ~/.ssh/id_zstack --vault-password-file ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key --output ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/id_zstack.vault 
  ```
  Run the following command to create encrypted Passphrase file: <br/>
  `ansible-vault create <target_passphrase_file> --vault-password-file </path/to/vault_key_file>`
  - Enter passphrase in plain text when prompted
  ```
  ansible-vault create ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/ibmuser_passphrase.vault --vault-password-file ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key 
  ```
 

## Verify Encrypted File Data
  To view data you can run the following command: <br/>
  `ansible-vault view <encrypted_filename> --vault-password-file </path/to/vault_key_file>`
  ```
  ansible-vault view  ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/zpmtest_registry_password.vault --vault-password-file ${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key
  ``` 

## Use Encrypted Secrets In Automation 
### Update SEAA config variables

### Export SEAA Environment Variable for Vault-Key file
Export `SEAA_ANSIBLE_VAULT_KEY_FILE` environment variable with path to Vault-Key file or add to profile or system env variables, for example:
  ```
  export SEAA_ANSIBLE_VAULT_KEY_FILE=${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets/vault_encrypted.key
  ```
  Once this is set you can run the automation run_playbooks script and the automation will decrypt your vault secrets located in the `${SEAA_CONFIG_PATH_TO_SE_ANSIBLE_ARTIFACTS}/secrets` directory

### How to Specifying Encrypt Secret text in Ansible Variables

### How to Specifying Encrypt Secret File in Ansible Variables
- Use encrypted registry password file
  <!-- - Set name of the encrypted sshkey file for `zpm_registry_password` variable
    ```
    zpm_registry_password: zpmtest_registry_password.vault
    ``` -->
  - Set name of the password file in `zpm_registries.password` dictionary variable
    ```
    "zpm_registries": [
      {
        "host": "us.icr.io/zpmtest", 
        "user": "iamapikey",
        "password" : "zpmtest_registry_password.vault"
      }
    ] 
    ```
- Use encrypted sshkey file
  - Set name of the encrypted sshkey file for `ansible_ssh_private_key_file` variable
    ```
    ansible_ssh_private_key_file: id_zstack.vault
    ```
- Use encrypted user passphrase file
  - Set name of the encrypted user passphrase file for `ssh_passphrase` variable
    ```
    ssh_passphrase: ibmuser_passphrase.vault
    ```
