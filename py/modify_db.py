# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from . import files
from . import db

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'modify_db.ui'))

class ModifyDB(QtWidgets.QDialog, FORM_CLASS):
    """Page de modification des extensions d'une base de données existante."""

    def __init__(self, parent=None):
        super(ModifyDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(files.load_pixmap("file/logo_full.png"))
        self.btnDbPath.clicked.connect(lambda: files.open_file_to_lineedit("Sélectionner un fichier", "Base SQLite (*.sqlite)", self.editDbPath))
        self.btnModify.clicked.connect(self.__modify_db_file)

    def __modify_db_file(self):
        """Crée la base de données en fonction des valeurs des champs."""
        path_db = self.editDbPath.text()
        if len(path_db) == 0 or not os.path.exists(path_db):
            # Informations manquantes
            self.labMsg.setText("Veuillez d'abord sélectionner une base de données.")
            return

        checked_ofd = self.checkOfTheDead.isChecked()
        checked_ah = self.checkAtHome.isChecked()
        
        if not checked_ofd and not checked_ah:
            self.labMsg.setText("Veuillez sélectionner au moins une extension à ajouter.")
            return

        # Création extensions
        if checked_ofd:
            db.exec_sql_file(path_db, db.SQL_OF_THE_DEAD)
        if checked_ah:
            db.exec_sql_file(path_db, db.SQL_AT_HOME)

        self.labMsg.setText("La base de données a été modifiée avec succès.")
