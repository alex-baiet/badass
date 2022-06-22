# BADASS

## Description

Le plugin BADASS facilite la création et la modification d'un projet BADASS :

- Il permet de créer un modèle de projet QGIS avec une base de données BADASS. La base de données peut être créer avec une ou plusieurs extensions aux choix.
- Un projet créer peut être modifier en ajoutant une ou plusieurs extensions.

## Structure

**ATTENTION**, Cette partie n'est que pour ceux qui souhaitent éditer/comprendre le code de ce projet.

Le projet est un plugin QGIS en *Python*, ses interfaces générées avec *QTCreator*.

Voici les différentes parties :

- Le script principal est `dialog_badass.py`, qui est exécuté au lancement du plugin. Il charge les différentes fenêtres et initialise les composants de navigation;
- Les différentes fenêtres visuelles sont les fichiers en `py/*.ui`, éditable avec QTCreator. Chacun des fichiers ont un script `.py` attaché du même nom, permettant de créer des instances de ces fenêtres et d'initialiser ces composants;
- Les autres scripts dans `py` contiennent des fonctions diverses;
- Le fichier `file/model.qgz` et ceux contenu dans le dossier `file/sql` servent à créer les nouveaux projets BADASS;
- Le dossier `file/original` contient un exemple d'utilisation du projet BADASS. Il n'est pas utiliser par le code;

## Histoire

Ce projet est un plugin QGIS commencé par **Alexandre HAMEAU** et **Emma CHAPUIS** en 2021 et continué par **Alex BAIET** (moi).

Alexandre HAMEAU et Emma CHAPUIS ont commencé le plugin durant leurs stages en ajoutant la création d'une base de données automatisée et en commençant la création de nombreuses interfaces d'édition de la base de données. A la fin de leur stages, le plugin n'était pas bien fonctionnel.

J'ai donc repris le projet et ai terminé ce plugin en juin 2022.
