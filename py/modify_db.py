# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from .helper import Helper

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'modify_db.ui'))

class ModifyDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de modification des extensions d'une base de données existante.
    """

    def __init__(self, parent=None):
        super(ModifyDB, self).__init__(parent)
        self.setupUi(self)

        self.logoFull.setPixmap(Helper.load_pixmap("file/logo_full.png"))
