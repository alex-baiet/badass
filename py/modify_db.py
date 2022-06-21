# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from . import helper

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'modify_db.ui'))

class ModifyDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de modification des extensions d'une base de données existante.
    """

    def __init__(self, parent=None):
        super(ModifyDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(helper.load_pixmap("file/logo_full.png"))
        self.btnDbPath.clicked.connect(lambda: helper.select_file_to_lineedit("Sélectionner un fichier", "Base SQLite (*.sqlite)", ".sqlite", self.editDbPath))
