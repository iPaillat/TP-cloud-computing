# Cloud Computing TP 2 Report    

I'm starting from the base of the previous TP, so the terraform environment is still present and I can make modifications and improvements to the same VM.

## A. Adding an NSG (Network Security Group)

I configure my network file to authorize only SSH from my public IP. I retrieve my public IP from the website [https://whatismyipaddress.com/](https://whatismyipaddress.com/) and enter it in the `terraform.tfvars` file in the `my_public_ip` variable.

I can then apply the configuration with the `terraform apply` command.

```bash
$ Terraform> terraform apply
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_network_interface_security_group_association.main will be created
  + resource "azurerm_network_interface_security_group_association" "main" {
      + id                        = (known after apply)
      + network_interface_id      = "/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Network/networkInterfaces/vm-nic"
      + network_security_group_id = (known after apply)
    }

[...]

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_network_interface_security_group_association.main: Creating...
azurerm_network_security_group.main: Creating...
azurerm_network_security_group.main: Creation complete after 2s [id=/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Network/networkSecurityGroups/vm-nsg-tp2]
azurerm_network_interface_security_group_association.main: Creation complete after 2s [id=/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Network/networkInterfaces/vm-nic/networkSecurityGroup]
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

If we run the command `az network nic show --resource-group TP1-Cloud-terraform --name vm-nic --query "networkSecurityGroup" -o json`, we can see that the NSG has been properly associated with the VM's network interface.

```bash
Terraform> az network nic show --resource-group TP1-Cloud-terraform --name vm-nic --query "networkSecurityGroup" -o json
{
  "id": "/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Network/networkSecurityGroups/vm-nsg-tp2",
  "resourceGroup": "TP1-Cloud-terraform"
}
```

Also we can connect via SSH to the VM from my public IP.

```bash
$ ssh paillat@<ip-publique>
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 [...]

Last login: Mon Sep 15 13:04:09 2025 from 216.252.179.121
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.
paillat@super-vm:~$
```

If we modify the SSH port on the VM (in the `/etc/ssh/sshd_config` file), for example changing it to port 2222, and restart the SSH service with `sudo systemctl restart ssh`, we can no longer connect via SSH from my public IP.   

```bash
ss -tulpen | grep tcp
tcp     LISTEN   0        4096       127.0.0.53%lo:53            0.0.0.0:*       uid:101 ino:19383 sk:5 <->
tcp     LISTEN   0        128              0.0.0.0:2222          0.0.0.0:*       ino:46660 sk:e <->
tcp     LISTEN   0        128                 [::]:2222             [::]:*       ino:46671 sk:f v6only:1 <->

ssh -p 2222 paillat@<ip-publique>
Connection closed by <ip-publique> port 2222
```

## B. A Little Domain Name for the VM

See the modifications in the `main.tf` and `outputs.tf` files.

```bash
$ Terraform> Terraform> terraform apply
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform]

[...]

Changes to Outputs:
  ~ vm_dns_name  = "super-vm-tp2.uksouth.cloudapp.azure.com" -> "super-vm-tp2"

You can apply this plan to save these new output values to the Terraform state, without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

vm_dns_name = "super-vm-tp2"
vm_public_ip = "<ip-publique>"
```

SSH connection using the domain name:

```bash
Terraform> ssh paillat@super-vm-tp2.uksouth.cloudapp.azure.com
The authenticity of host 'super-vm-tp2.uksouth.cloudapp.azure.com (<ip-publique>)' can't be established.
ED25519 key fingerprint is SHA256:eIqM2Z7VpJwCNEay45aIyAgOxU6HfFIvWwleIodLdCI.
This host key is known by the following other names/addresses:
    C:\Users\paillat/.ssh/known_hosts:7: <ip-publique>
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'super-vm-tp2.uksouth.cloudapp.azure.com' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

[...]

Last login: Tue Sep 16 09:33:32 2025 from 216.252.179.122
paillat@super-vm:~$
```

# C. Blob Storage

See the modifications in the `storage.tf` file.
Installing azCopy on the VM:

```bash
paillat@super-vm:~$ wget https://aka.ms/downloadazcopy-v10-linux

[...]

downloadazcopy-v10-linux      100%[=================================================>]  22.03M  --.-KB/s    in 0.1s

2025-09-16 13:13:11 (219 MB/s) - 'downloadazcopy-v10-linux' saved [23102827/23102827]
paillat@super-vm:~$ tar -xvf downloadazcopy-v10-linux
azcopy_linux_amd64_10.30.1/
azcopy_linux_amd64_10.30.1/azcopy
azcopy_linux_amd64_10.30.1/NOTICE.txt
paillat@super-vm:~$ sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/
paillat@super-vm:~$ azcopy --version
azcopy version 10.30.1
```

Logging in to azcopy:

```bash
paillat@super-vm:~$ azcopy login --identity
You have successfully logged in.
```
How does this command work?
1 - Retrieving the Azure VM instance ID via a metadata endpoint.
2 - The endpoint returns a JWT token signed by Azure AD.
3 - Finally, Azure Storage validates this token if the VM has the necessary permissions to access the storage service.

Creating a test.txt file and uploading it to the blob container:

```bash
paillat@super-vm:~$ echo "Hello Terraform Blob Storage" > test.txt

paillat@super-vm:~$ azcopy copy test.txt "https://tp2storageacc.blob.core.windows.net/meowcontainer" --recursive
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to destination using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

Job df266af6-b7c9-8446-593d-992377b1e87c has started
Log file is located at: /home/paillat/.azcopy/df266af6-b7c9-8446-593d-992377b1e87c.log

100.0 %, 1 Done, 0 Failed, 0 Pending, 0 Skipped, 1 Total, 2-sec Throughput (Mb/s): 0.0001

Job df266af6-b7c9-8446-593d-992377b1e87c summary
Elapsed Time (Minutes): 0.0334
Number of File Transfers: 1
Number of Folder Property Transfers: 0
Number of Symlink Transfers: 0
Total Number of Transfers: 1
Number of File Transfers Completed: 1
Number of Folder Transfers Completed: 0
Number of File Transfers Failed: 0
Number of Folder Transfers Failed: 0
Number of File Transfers Skipped: 0
Number of Folder Transfers Skipped: 0
Number of Symbolic Links Skipped: 0
Number of Hardlinks Converted: 0
Number of Special Files Skipped: 0
Total Number of Bytes Transferred: 29
Final Job Status: Completed
```

Verifying that the file is properly in the blob container:

```bash
paillat@super-vm:~/telecharger$ azcopy copy "https://tp2storageacc.blob.core.windows.net/meowcontainer/test.txt" ./ --recursive
 test.txt
INFO: Discarding incorrectly formatted input message
INFO: Scanning...
INFO: Autologin not specified.
INFO: Authenticating to source using Azure AD
INFO: Any empty folders will not be processed, because source and/or destination doesn't have full folder support

[...]

Total Number of Bytes Transferred: 29
Final Job Status: Completed

paillat@super-vm:~/telecharger$ ls
test.txt
paillat@super-vm:~/telecharger$ cat test.txt
Hello Terraform Blob Storage
```

Manual request with curl (without azcopy):

```bash
paillat@super-vm:~$  curl -H "Metadata:true" -X GET "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/"
{"access_token":"eyJ0eXAiOi[...]lUyzVZ6ykl_Q","client_id":"efa0882e-47cb-4010-b3e0-4c15fb63b43a","expires_in":"86400","expires_on":"1758117912","ext_expires_in":"86399","not_before":"1758031212","resource":"https://storage.azure.com/","token_type":"Bearer"}
paillat@super-vm:~$ 
```

The IP `169.254.169.254` is reachable because Azure adds a special route in the VM's routing table. This route allows local access to the metadata service, without going through the Internet.

## D. Monitoring

See the `monitoring.tf` file.

Once the alerts are created, we can verify in the Azure portal that everything is properly in place.

```bash
az monitor metrics alert list --output table
AutoMitigate    Description                                          Enabled    EvaluationFrequency    Location    Name                   ResourceGroup        Severity    TargetResourceRegion    TargetResourceType    WindowSize
--------------  ---------------------------------------------------  ---------  ---------------------  ----------  ---------------------  -------------------  ----------  ----------------------  --------------------  ------------
True            Alert when CPU usage exceeds 70%                     True       PT1M                   global      cpu-alert-super-vm     TP1-Cloud-terraform  2                                                         PT5M
True            Alert if VM has less than 512 MB available RAM       True       PT1M                   global      memory-alert-super-vm  TP1-Cloud-terraform  2                                                         PT5M
PS C:\windows\system32>
```

We can then stress the VM to trigger the alerts. For this, I install the `stress` package on the VM.

```bash
sudo apt-get update
sudo apt-get install -y stress
```
Then I run the following command to stress the CPU and RAM:

```bash
stress-ng --cpu 3 --cpu-load 90 --timeout 600s 
stress-ng --vm 3 --vm-bytes 600M --timeout 600s
```
After a few minutes, I properly receive the alerts by email.

```bash
az monitor activity-log list --query "[].{Operation:operationName.value, RG:resourceGroupName, Caller:caller}" --output table
Operation                                           RG                   Caller
--------------------------------------------------  -------------------  -----------------
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD            Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD-TERRAFORM  Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD            Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD-TERRAFORM  Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action                       Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action                       Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD            Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action                       Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action                       Microsoft.Advisor
Microsoft.Advisor/recommendations/available/action  TP1-CLOUD            Microsoft.Advisor
```

# E. Vault

See the `vault.tf` file.

After applying the terraform configuration, I can connect to the vault and store a secret in it.

```bash
Terraform> az keyvault secret show --name "meow-secret" --vault-name "kv-TP1-Cloud-terraform"
{
  "attributes": {
    "created": "2025-09-17T09:05:40+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoverableDays": 7,
    "recoveryLevel": "CustomizedRecoverable+Purgeable",
    "updated": "2025-09-17T09:05:40+00:00"
  },
  "contentType": "",
  "id": "https://kv-tp1-cloud-terraform.vault.azure.net/secrets/meow-secret/bfeac1161fe24844b57586f60ac1ee23",
  "kid": null,
  "managed": null,
  "name": "meow-secret",
  "tags": {},
  "value": "E)IBL50o@o0gMG)9"
}
```

We can also retrieve this secret from the VM using a bash script.
I previously installed az cli on the VM.

```bash
#!/bin/bash

# Key Vault name
VAULT_NAME="kv-TP1-Cloud-terraform"

# Secret name
SECRET_NAME="meow-secret"

# Retrieve the secret with Azure CLI
SECRET_VALUE=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME --query value -o tsv)

echo "The secret is: $SECRET_VALUE"
```

I make the script executable with `chmod +x get_secret.sh` and execute it.

```bash
paillat@super-vm:~$ chmod +x script-kv.sh
paillat@super-vm:~$ ./script-kv.sh
The secret is: E)IBL50o@o0gMG)9
```

# F. Conclusion

There you go!