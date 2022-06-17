# -*- coding: utf-8 -*-
"""
/***************************************************************************
 DialogBADASSDialog
                                 A QGIS plugin
 Extention permettant l'accès à l'interface BADASS
 Generated by Plugin Builder: http://g-sherman.github.io/Qgis-Plugin-Builder/
                             -------------------
        begin                : 2021-04-12
        git sha              : $Format:%H$
        copyright            : (C) 2021 by Alexandre Humeau
        email                : alexandre.humeau1@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

import os

from qgis.PyQt import uic
from qgis.PyQt import QtWidgets
from PyQt5.QtWidgets import *
from PyQt5 import QtCore
from PyQt5.QtCore import *
from PyQt5 import QtGui
from PyQt5.QtGui import *
from .form4_entitearcheo1 import DialogBADASSForm4Entitearcheo1
from .form4_entitearcheo2 import DialogBADASSForm4Entitearcheo2
from .form4_entitearcheo3 import DialogBADASSForm4Entitearcheo3
from .form4_entitearcheo4 import DialogBADASSForm4Entitearcheo4
from .expression import *
# This loads your .ui file so that PyQt can populate your plugin with the elements from Qt Designer
FORM_CLASS, _ = uic.loadUiType(os.path.join(
    os.path.dirname(__file__), 'form3_entite_archeo.ui'))


class DialogBADASSForm3EntiteArcheo(QtWidgets.QDialog, FORM_CLASS):
    def __init__(self, parent=None):
        """Constructor."""
        super(DialogBADASSForm3EntiteArcheo, self).__init__(parent)
        # Set up the user interface from Designer through FORM_CLASS.
        # After self.setupUi() you can access any designer object by doing
        # self.<objectname>, and you can use autoconnect slots - see
        # http://qt-project.org/doc/qt-4.8/designer-using-a-ui-file.html
        # #widgets-and-dialogs-with-auto-connect
        self.setupUi(self)
        self.filtre_type="ensemble"
        #On charge le tableau liée au filtre par défaut
        self.charge_ensemble_tab()

        #Lorsque l'élément de la QCombobox change le tableau va changer en conséquence
        self.typoly.currentTextChanged.connect(self.combobox_changed)

        self.new_archeo_bouton.clicked.connect(self.button_push)
        """
        Quelles fenêtres va être appelé lorsque le bouton nouvelle entité va être sélectionné, la fenêtre du filtre ?
        """
        #Ecouteur d'evènement sur le tableau
        self.tableView_archeo.doubleClicked.connect(self.modifier_enregistrement)
        #fenetre expression
        self.rechercher.clicked.connect(lambda: expression_dialog(self,iface))

    """
    Les méthodes suivantes vont permettre de changer le tableau affiché en fonction du type de filtre selectionner
    """
    def combobox_changed(self, value):
        #On modifie la valeur du filtre de type
        self.filtre_type = value
        #On change le tableau
        self.change_tab()

    def change_tab(self):
        #On cherche à soir quelle est le filtre type afin d'appelé la méthode approprié
        if self.filtre_type == 'ensemble':
            self.charge_ensemble_tab()
        elif self.filtre_type == 'fait':
            self.charge_fait_tab()
        elif self.filtre_type == 'unité stratigraphique':
            self.charge_unite_stratigraphique_tab()
        elif self.filtre_type == 'composante':
            self.charge_composante_tab()

    def charge_ensemble_tab(self):
        #Les éléments du tableau ne sont pas clairement définis
        #Le model choisie pour l'instant est le plus adapté à un QTableView
        self.model = QStandardItemModel(10, 10)
        self.tableView_archeo.setModel(self.model)
        #Les données sont bidons, elles permettent d'avoir un aperçu d'un tableau rempli
        for i in range(10):
                for j in range(10):
                    item = QStandardItem(str(i+j))
                    self.model.setItem(i,j,item)
        #Quelques méthodes utiles pour cacher les en-têtes et changer leur contenue
        #self.tableView_archeo.horizontalHeader().setVisible(False)
        #self.ui.tblContents.verticalHeader().setVisible(False)
        #self.model.setHorizontalHeaderLabels(['2','1','2'])

    def charge_fait_tab(self):
        #Les éléments du tableau ne sont pas clairement définis
        #Le model choisie pour l'instant est le plus adapté à un QTableView
        self.model = QStandardItemModel(5, 2)
        self.tableView_archeo.setModel(self.model)
        #Les données sont bidons, elles permettent d'avoir un aperçu d'un tableau rempli
        for i in range(5):
                for j in range(2):
                    item = QStandardItem(str(i+j))
                    self.model.setItem(i,j,item)
        #Quelques méthodes utiles pour cacher les en-têtes et changer leur contenue
        #self.tableView_archeo.horizontalHeader().setVisible(False)
        #self.ui.tblContents.verticalHeader().setVisible(False)
        #self.model.setHorizontalHeaderLabels(['2','1','2'])

    def charge_unite_stratigraphique_tab(self):
        #Les éléments du tableau ne sont pas clairement définis
        #Le model choisie pour l'instant est le plus adapté à un QTableView
        self.model = QStandardItemModel(5, 3)
        self.tableView_archeo.setModel(self.model)
        #Les données sont bidons, elles permettent d'avoir un aperçu d'un tableau rempli
        for i in range(5):
                for j in range(3):
                    item = QStandardItem(str(i+j))
                    self.model.setItem(i,j,item)
        #Quelques méthodes utiles pour cacher les en-têtes et changer leur contenue
        #self.tableView_archeo.horizontalHeader().setVisible(False)
        #self.ui.tblContents.verticalHeader().setVisible(False)
        #self.model.setHorizontalHeaderLabels(['2','1','2'])

    def charge_composante_tab(self):
        #Les éléments du tableau ne sont pas clairement définis
        #Le model choisie pour l'instant est le plus adapté à un QTableView
        self.model = QStandardItemModel(5, 4)
        self.tableView_archeo.setModel(self.model)
        #Les données sont bidons, elles permettent d'avoir un aperçu d'un tableau rempli
        for i in range(5):
                for j in range(4):
                    item = QStandardItem(str(i+j))
                    self.model.setItem(i,j,item)
        #Quelques méthodes utiles pour cacher les en-têtes et changer leur contenue
        #self.tableView_archeo.horizontalHeader().setVisible(False)
        #self.ui.tblContents.verticalHeader().setVisible(False)
        #self.model.setHorizontalHeaderLabels(['2','1','2'])

    """
    Les méthodes suivantes vont permettre de d'appeler la bonne fenetre parmis les form4_entitearcheo[1,2,3,4]
    Soit quant le bouton nouvelle entité est pressé
    Soit quand une ligne du tableau est selectionner
    """

    def button_push(self):
        #On cherche à soir quelle est le filtre type afin d'appelé la méthode approprié
        if self.filtre_type == 'ensemble':
            self.entitearcheo1()
        elif self.filtre_type == 'fait':
            self.entitearcheo2()
        elif self.filtre_type == 'unité stratigraphique':
            self.entitearcheo3()
        elif self.filtre_type == 'composante':
            self.entitearcheo4()


    def modifier_enregistrement(self):
        #Récupère la case qui à été double cliqué
        for idx in self.tableView_archeo.selectionModel().selectedIndexes():
            row_number = idx.row()
            column_number = idx.column()
        #On recupère les données de la ligne
        donnees='des donnees'
        #On passe en paramtre du constructeur les élements nécessaire
        if self.filtre_type == 'ensemble':
            self.entitearcheo1(donnees)
        elif self.filtre_type == 'fait':
            self.entitearcheo2(donnees)
        elif self.filtre_type == 'unité stratigraphique':
            self.entitearcheo3(donnees)
        elif self.filtre_type == 'composante':
            self.entitearcheo4(donnees)

    def entitearcheo1(self, donnees=None):
        self.fenetre4_entitearcheo1 = DialogBADASSForm4Entitearcheo1(donnees)
        # show the dialog
        self.fenetre4_entitearcheo1.show()

    def entitearcheo2(self, donnees=None):
        self.fenetre4_entitearcheo2 = DialogBADASSForm4Entitearcheo2(donnees)
        # show the dialog
        self.fenetre4_entitearcheo2.show()

    def entitearcheo3(self, donnees=None):
        self.fenetre4_entitearcheo3 = DialogBADASSForm4Entitearcheo3(donnees)
        # show the dialog
        self.fenetre4_entitearcheo3.show()

    def entitearcheo4(self, donnees=None):
        self.fenetre4_entitearcheo4 = DialogBADASSForm4Entitearcheo4(donnees)
        # show the dialog
        self.fenetre4_entitearcheo4.show()