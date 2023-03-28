# BADASS

This plugin only target french archaeologicals organizations, so most of his content is only in french without any translation.
It is used to generate projects with a database from specific models.

## Description

Le plugin BADASS facilite la création et la modification d'un projet BADASS :

- Il permet de créer un modèle de projet QGIS avec une base de données BADASS. La base de données peut être créer avec une ou plusieurs extensions aux choix.
- Un projet créer peut être modifier en ajoutant une ou plusieurs extensions.

## Structure

Le projet est un plugin QGIS en *Python*, ses interfaces générées avec *QTCreator*.

Voici les différentes parties :

- Le script principal est `dialog_badass.py`, qui est exécuté au lancement du plugin. Il charge les différentes fenêtres et initialise les composants de navigation;
- Les différentes fenêtres visuelles sont les fichiers en `py/*.ui`, éditable avec *QTCreator*. Chacun des fichiers ont un script `.py` attaché du même nom, permettant de créer des instances de ces fenêtres et d'initialiser ces composants;
- Les autres scripts dans `py` contiennent des fonctions diverses;
- Le fichier `file/model.qgz` et ceux contenu dans le dossier `file/sql` servent à créer les nouveaux projets BADASS. Les fichiers SQL sont séparés en morceaux avec le séparateur `/*--*/` pour éviter que l'application freeze lors de la création de la base de données;

## Histoire

Ce projet est un plugin QGIS commencé par **Alexandre HAMEAU** et **Emma CHAPUIS** en 2021 et continué par **Alex BAIET** en 2022.

Alexandre HAMEAU et Emma CHAPUIS ont commencé le plugin durant leurs stages en ajoutant la création d'une base de données automatisée et en commençant la création de nombreuses interfaces d'édition de la base de données. A la fin de leur stages, le plugin n'était pas bien fonctionnel.
Alex BAIET a donc repris et terminé le projet en juin 2022.

## Mettre à jour le plugin

Pour avoir les droits de modification du plugin et les identifiants pour QGIS, contactez [alex.baiet3@gmail.com](mailto:alex.baiet3@gmail.com).

Le code source est disponible sur [https://github.com/alex-baiet/badass/](https://github.com/alex-baiet/badass/), où tout l'historique des versions est disponible.

Le plugin est disponible parmis les plugins officiels de QGIS. Pour modifier la version en ligne, il faut :
- Se connecter via cette page : [https://plugins.qgis.org/accounts/login/](https://plugins.qgis.org/accounts/login/);
- Accéder à la page suivantes : [https://plugins.qgis.org/plugins/badass/](https://plugins.qgis.org/plugins/badass/) ou les différentes versions peuvent être mis à jour.
