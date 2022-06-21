# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from qgis.PyQt.QtWidgets import QLineEdit, QFileDialog, QLabel
from qgis.core import QgsMessageLog
from . import helper
from . import db

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'create_db.ui'))

class CreateDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de création d'une nouvelle base de donnée.
    """
    def __init__(self, parent=None):
        super(CreateDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(helper.load_pixmap("file/logo_full.png"))
        self.btnDbPath.clicked.connect(lambda: helper.select_file_to_lineedit("Sélectionner un fichier", "Base SQLite (*.sqlite)", ".sqlite", self.editDbPath))
        self.btnQgzPath.clicked.connect(lambda: helper.select_file_to_lineedit("Sélectionner un fichier", "Projet QGIS (*.qgz)", ".qgz", self.editQgzPath))
        self.btnCreate.clicked.connect(lambda: self.__create_db_file())

    def __create_db_file(self):
        """Crée la base de données en fonction des valeurs des champs."""
        path_db = self.editDbPath.text()
        if len(path_db) == 0:
            # Informations manquantes
            self.labMsg.setText("Veuillez d'abord choisir un chemin pour la base de données.")
            return
        
        # Création bdd
        db.create_bdd(path_db)
        self.labMsg.setText("La base de données a été créée avec succès.")
        
        # Création extensions
        if self.checkOfTheDead.isChecked():
            db.add_of_the_dead_ext(path_db)
        if self.checkAtHome.isChecked():
            db.add_at_home_ext(path_db)
