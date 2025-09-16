# Cloud Computing TP 1 Report    

## Prerequisites

### A. Choice of Encryption Algorithm

For several years, the RSA signature algorithm (based on SHA-1) has become outdated, particularly due to certain known vulnerabilities. It has even been disabled by default in OpenSSH since version 8.8.

- [Source: OpenSSH release](https://www.openssh.com/txt/release-8.2)

It is preferable to choose algorithms such as Ed25519, which are more secure, performant, and faster to generate.

- [Source: Ethersys](https://www.ethersys.fr/actualites/20241022-quelle-cle-ssh-generer/#:~:text=La%20meilleure%20cl%C3%A9%20SSH%20d%C3%A9pend,un%20compromis%20entre%20les%20deux.)

### B. Generating My Key Pair

Key pair generation using the following command:

`ssh-keygen -t ed25519  -f ~/.ssh/cloud_tp1`

Generates two files:
- cloud_tp1.pub **(public key)**
- cloud_tp1 **(private key)**

## VM Deployment

### A. From the WebUI

Command: `PS C:\Users\paillat> ssh azureuser@172.187.219.50`

Result: `azureuser@Loulou:~$` (visual of the prompt)

### B. With Azure Commands

Command to create my VM with `az`:

``` bash
az group create --location uksouth --name TP1-Cloud

az vm create -g TP1-Cloud -n loulou --image Ubuntu2204 --admin-username paillat --ssh-key-values ~/.ssh/id_ed25519.pub --size Standard_B1s
```

Presence of the **walinuxagent.service** service:
``` bash
paillat@loulou:~$ systemctl status walinuxagent.service
 walinuxagent.service - Azure Linux Agent
     Loaded: loaded (/lib/systemd/system/walinuxagent.service; enabled; vendor preset: enabled)
    Drop-In: /run/systemd/system.control/walinuxagent.service.d
             └─50-CPUAccounting.conf, 50-MemoryAccounting.conf
     Active: active (running) since Mon 2025-09-15 08:26:47 UTC; 34min ago
   Main PID: 719 (python3)
      Tasks: 7 (limit: 1009)
     Memory: 45.2M
        CPU: 4.108s
     CGroup: /system.slice/walinuxagent.service
             ├─ 719 /usr/bin/python3 -u /usr/sbin/waagent -daemon
             └─1025 python3 -u bin/WALinuxAgent-2.14.0.1-py3.12.egg -run-exthandlers
```
And the **cloud-init.service** service:
``` bash
paillat@loulou:~$ systemctl status cloud-init.service
● cloud-init.service - Cloud-init: Network Stage
     Loaded: loaded (/lib/systemd/system/cloud-init.service; enabled; vendor preset: enabled)
     Active: active (exited) since Mon 2025-09-15 08:26:46 UTC; 36min ago
   Main PID: 483 (code=exited, status=0/SUCCESS)
        CPU: 1.361s
```

### C. With Terraform

I installed terraform by adding it to my **$PATH** environment variable

``` bash
PS C:\Users\paillat> terraform -v
Terraform v1.13.2
on windows_amd64
```

Create my folder and initialize *terraform*

``` bash
mkdir Terraform
$ \Terraform> terraform init
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v4.44.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

To see the resources that will be modified/created/deleted:

``` bash
$ \Terraform> terraform plan
[...]
# azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space                  = [
          + "10.0.0.0/16",
        ]
      + dns_servers                    = (known after apply)
      + guid                           = (known after apply)
      + id                             = (known after apply)
      + location                       = "uksouth"
      + name                           = "vm-vnet"
      + private_endpoint_vnet_policies = "Disabled"
      + resource_group_name            = "TP1-Cloud-terraform"
      + subnet                         = (known after apply)
    }

Plan: 6 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
```

Finally, we create the VM using the main.tf file:

``` bash
$ \Terraform> terraform apply
[...]
azurerm_linux_virtual_machine.main: Creating...
azurerm_linux_virtual_machine.main: Still creating... [00m10s elapsed]
azurerm_linux_virtual_machine.main: Still creating... [00m20s elapsed]
azurerm_linux_virtual_machine.main: Still creating... [00m30s elapsed]
azurerm_linux_virtual_machine.main: Still creating... [00m40s elapsed]
azurerm_linux_virtual_machine.main: Creation complete after 50s [id=/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Compute/virtualMachines/super-vm]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

After adding a rule on port 22 of my VM, I can connect to it with an `ssh` command:

``` 
$ \Terraform> ssh paillat@<ip-publique-de-la-vm>
The authenticity of host '<ip-publique-de-la-vm>' can't be established.
Warning: Permanently added '<ip-publique-de-la-vm>' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

[...]

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

paillat@super-vm:~$
```

Finally, to delete resources, we can execute the `terraform destroy` command.