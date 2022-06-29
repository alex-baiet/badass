# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from qgis.PyQt.QtWidgets import QLineEdit, QFileDialog, QLabel
from qgis.core import QgsMessageLog
from . import files
from . import db
from . import qgz

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'create_db.ui'))

# Nom par défaut du fichier qgz
DEFAULT_QGZ_NAME = "Badass"
# Nom par défaut de la nouvelle bdd
DEFAULT_DB_NAME = "badass"

class CreateDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de création d'une nouvelle base de donnée.
    """
    def __init__(self, parent=None):
        super(CreateDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(files.load_pixmap("file/logo_full.png"))
        self.btnDirPath.clicked.connect(lambda: files.save_dir_to_lineedit("Choisissez le dossier du projet", self.editDirPath))
        self.btnCreate.clicked.connect(self.__generate_files)

    def __generate_files(self):
        """Crée la base de données en fonction des valeurs des champs."""
        path_dir = self.editDirPath.text()
        if len(path_dir) == 0:
            # Informations manquantes
            self.labMsg.setText("Veuillez d'abord choisir un dossier.")
            return
        
        if not os.path.exists(path_dir):
            self.labMsg.setText("Le dossier sélectionné n'existe pas.")
            return

        qgz_name = self.editQgzName.text()
        if len(qgz_name) == 0:
            qgz_name = DEFAULT_QGZ_NAME

        db_name = self.editDbName.text()
        if len(db_name) == 0:
            db_name = DEFAULT_DB_NAME

        sql_files = [db.SQL_MAIN]
        if self.checkOfTheDead.isChecked():
            sql_files.append(db.SQL_OF_THE_DEAD)
        if self.checkAtHome.isChecked():
            sql_files.append(db.SQL_AT_HOME)

        ### Création qgz ###
        qgz.create_project(path_dir, qgz_name + ".qgz", db_name + ".sqlite", sql_files)

        self.labMsg.setText("Le projet a été créé avec succès.")

