# Cloud Computing TP 2 Report    

Je repars de la base du TP précédent, donc l'environnement terraform est toujous présent et donc je peux lui apporter des modifications et des améliorations sur la même VM.

## A. Ajout d'un NSG (Network Security Group)

Je configure mon fichier network pour autoriser uniquement le SSH depuis mon IP publique. Je récupère mon IP publique sur le site [https://whatismyipaddress.com/](https://whatismyipaddress.com/) et je la renseigne dans le fichier `terraform.tfvars` dans la variable `my_public_ip`.

Je peux ensuite appliquer la configuration avec la commande `terraform apply`.

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

Si l'on fait la commande `az network nic show --resource-group TP1-Cloud-terraform --name vm-nic --query "networkSecurityGroup" -o json`, on peut voir que le NSG a bien été associé à la carte réseau de la VM.

```bash
Terraform> az network nic show --resource-group TP1-Cloud-terraform --name vm-nic --query "networkSecurityGroup" -o json
{
  "id": "/subscriptions/ea37b6d9-5862-488d-8916-ad75a2ba0af2/resourceGroups/TP1-Cloud-terraform/providers/Microsoft.Network/networkSecurityGroups/vm-nsg-tp2",
  "resourceGroup": "TP1-Cloud-terraform"
}
```

Aussi on peut se connecter en SSH à la VM depuis mon IP publique.

```bash
$ ssh paillat@<ip-publique-de-la-vm>
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

Si on modifie sur la VM le port SSH (dans le fichier `/etc/ssh/sshd_config`), par exemple en le passant au port 2222, et que l'on redémarre le service SSH avec `sudo systemctl restart ssh`, on ne peut plus se connecter en SSH depuis mon IP publique.   

```bash
ss -tulpen | grep tcp
tcp     LISTEN   0        4096       127.0.0.53%lo:53            0.0.0.0:*       uid:101 ino:19383 sk:5 <->
tcp     LISTEN   0        128              0.0.0.0:2222          0.0.0.0:*       ino:46660 sk:e <->
tcp     LISTEN   0        128                 [::]:2222             [::]:*       ino:46671 sk:f v6only:1 <->

ssh -p 2222 paillat@<ip-publique-de-la-vm>
Connection closed by <ip-publique-de-la-vm> port 2222
```

## B. Un ptit nom de domaine pour la VM

Voir les modifications dans le fichier `main.tf` et `outputs.tf`.

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
vm_public_ip = "20.0.76.20"
```

Connection en SSH avec le nom de domaine :

```bash
Terraform> ssh paillat@super-vm-tp2.uksouth.cloudapp.azure.com
The authenticity of host 'super-vm-tp2.uksouth.cloudapp.azure.com (20.0.76.20)' can't be established.
ED25519 key fingerprint is SHA256:eIqM2Z7VpJwCNEay45aIyAgOxU6HfFIvWwleIodLdCI.
This host key is known by the following other names/addresses:
    C:\Users\paillat/.ssh/known_hosts:7: 20.0.76.20
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'super-vm-tp2.uksouth.cloudapp.azure.com' (ED25519) to the list of known hosts.
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1089-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Sep 16 10:07:51 UTC 2025

  System load:  0.05              Processes:             110
  Usage of /:   5.9% of 28.89GB   Users logged in:       0
  Memory usage: 30%               IPv4 address for eth0: 10.0.1.4
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Tue Sep 16 09:33:32 2025 from 216.252.179.122
paillat@super-vm:~$
```







