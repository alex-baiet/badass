# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from . import files

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'home.ui'))

class Home(QtWidgets.QDialog, FORM_CLASS):
    """
    Page d'accueil du plugin.
    """

    def __init__(self, parent=None):
        super(Home, self).__init__(parent)
        self.setupUi(self)
        
        self.logoFull.setPixmap(files.load_pixmap("file/logo_full.png"))
