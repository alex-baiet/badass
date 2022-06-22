# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from qgis.PyQt.QtWidgets import QLineEdit, QFileDialog, QLabel
from qgis.core import QgsMessageLog
from . import helper
from . import db
from . import qgz

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'create_db.ui'))

# Nom par défaut du fichier qgz
DEFAULT_QGZ_NAME = "Badass"
# Nom par défaut de la nouvelle bdd
DEFAULT_DB_NAME = "badass_otd_v2.sqlite"

class CreateDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de création d'une nouvelle base de donnée.
    """
    def __init__(self, parent=None):
        super(CreateDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(helper.load_pixmap("file/logo_full.png"))
        self.btnDirPath.clicked.connect(lambda: helper.save_dir_to_lineedit("Choisissez le dossier du projet", self.editDirPath))
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

        name = self.editName.text()
        if len(name) == 0:
            name = DEFAULT_QGZ_NAME

        ### Création bdd ###
        path_db = os.path.join(path_dir, DEFAULT_DB_NAME)
        db.create_db(path_db)
        # Création extensions
        if self.checkOfTheDead.isChecked():
            db.add_of_the_dead_ext(path_db)
        if self.checkAtHome.isChecked():
            db.add_at_home_ext(path_db)
        
        ### Création qgz ###
        qgz.create_qgz(os.path.join(path_dir, name) + ".qgz")
        
        self.labMsg.setText("Le projet a été créé avec succès.")

