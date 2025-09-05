# Rendu TP 1 CLoud computing    

## Prérequis

### A. Choix de l'algorithme de chiffrement

epuis quelques années, l’algorithme de signature RSA (basé sur SHA-1) est dépassé, notamment à cause de certaines vulnérabilités connues. Il a d’ailleurs été désactivé par défaut dans OpenSSH depuis la version 8.8.

- [Source : OpenSSH release](https://www.openssh.com/txt/release-8.2)

Il est préférable de choisir des algorithmes tels que Ed25519, plus sûrs, performants et rapides à générer.

- [Source : Ethersys](https://www.ethersys.fr/actualites/20241022-quelle-cle-ssh-generer/#:~:text=La%20meilleure%20cl%C3%A9%20SSH%20d%C3%A9pend,un%20compromis%20entre%20les%20deux.)

### B. Génération de ma paire de clés

Génération de la paire de clés grâce à la commande suivante:

`ssh-keygen -t ed25519  -f ~/.ssh/cloud_tp1`

Me génère deux fichiers:
- cloud_tp1.pub **(clé publique)**
- cloud_tp1 **(clé privé)**

## Spawn des VMs

### A. Depuis la WebUI

Commande : `PS C:\Users\paillat> ssh azureuser@172.187.219.50`

Resultat : `azureuser@Loulou:~$` (visuel du prompt)

### B. Avec les commandes Azure

Commande pour créer ma VM avec `az` :

```
az group create --location uksouth --name meo

az vm create 
    -g meo 
    -n super_vm 
    --image Ubuntu2204 
    --admin-username azureuser
    --ssh-key-values ~/.ssh/id_ed25519.pub
```

### C. Avec Terraform




