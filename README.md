# SubnetInfo PowerShell Script

Ce script PowerShell permet de calculer et d’afficher des informations détaillées sur un réseau IP en fonction d’un CIDR donné, avec option d’indiquer une adresse IP réseau.

---

## Fonctionnalités

- Affiche le masque de sous-réseau en notation décimale et binaire.
- Affiche le CIDR et le nombre de bits réservés aux hôtes.
- Calcule le nombre d’hôtes utilisables dans le réseau.
- Si une adresse IP réseau est fournie, calcule :
  - L’adresse réseau
  - L’adresse broadcast
  - La plage d’adresses hôtes utilisables

---

## Prérequis

- PowerShell 5.1 ou supérieur (fonctionne aussi sur PowerShell Core)

---

## Utilisation

1. Clonez ou téléchargez ce dépôt.
2. Ouvrez PowerShell dans le dossier du script.
3. Lancez le script :

```powershell
.\SubnetInfo.ps1
