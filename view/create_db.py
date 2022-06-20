# -*- coding: utf-8 -*-

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets

FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'create_db.ui'))

class CreateDB(QtWidgets.QDialog, FORM_CLASS):
    """
    Page de création d'une nouvelle base de donnée.
    """

    def __init__(self, parent=None):
        super(CreateDB, self).__init__(parent)
        self.setupUi(self)
