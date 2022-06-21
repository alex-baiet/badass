# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from qgis.PyQt.QtWidgets import QLineEdit, QFileDialog
from qgis.core import QgsMessageLog
from .helper import Helper
from .db import DB

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'create_db.ui'))

class CreateDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de création d'une nouvelle base de donnée.
    """
    def __init__(self, parent=None):
        super(CreateDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(Helper.load_pixmap("file/logo_full.png"))
        self.btnDbPath.clicked.connect(lambda: Helper.select_file_to_lineedit("Sélectionner un fichier", "Base SQLite (*.sqlite)", ".sqlite", self.editDbPath))
        self.btnQgzPath.clicked.connect(lambda: Helper.select_file_to_lineedit("Sélectionner un fichier", "Projet QGIS (*.qgz)", ".qgz", self.editQgzPath))

    def __create_db_file(self):
        """Crée la base de données en fonction des valeurs des champs."""
        
        