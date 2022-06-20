import re
from qgis.core import QgsApplication
import os

def get_file_path(name_file):
    """
    Renvoie le chemin absolue du fichier.
    Args:
        name_file (str): Nom du chemin relatif du fichier
    Returns:
        str: Chemin absolue
    """
    path_profil=QgsApplication.qgisSettingsDirPath()
    #path_file=path_profil+'python\plugins\dialog_badass\\'+name_file
    path_file=os.path.dirname(os.path.realpath(__file__))+ os.path.sep + name_file
    return path_file

############################################################
#
# FONCTIONS A TRIER
#
############################################################

#Cette fonction permet de récupérer les noms de tables spatiale, afin d'ajouter des couches seulement pour les tables spatiales
def recup_tables_spatiales(sql_code):
    try:
        res_tables=[]
        #CREATE TABLE ([a-z_]*)\((\n {3}[1-9a-z"\'\_A-Z ,\n\(\)-]*);\nSELECT\nAddGeometryColumn
        regex = re.compile(r'CREATE TABLE ([a-z_]*)\(([^;]*);\nSELECT\nAddGeometryColumn')
        res_regex_tables = regex.findall(sql_code)
        for element in res_regex_tables:
            res_tables.append(element[0])
        return res_tables
    except Exception as e:
        raise


#Le bouton Ouvrir une base existante permet l'accès à une fenêtre d'explorateur (fonction *Parcourir*)
#pour charger le fichier .sqlite d'une précédente base.
def ouvrir_base_existante(self):
    path_file = self.open_output_file()
    #Si la personne à cliquer sur annulée le chemin est vide
    if path_file!="":
        #On informe l'utilisateur que l'action est en cours
        #self.iface.messageBar().pushMessage("Information", "L'ouverture est en cours", level=Qgis.Info, duration=2)
        #On crée la connexion_bdd
        conn = connexion_bdd(path_file)
        db = connexion_sqldb(path_file)
        #On récupère le nom des tables présent dans la bdd, afin les chargers
        res_tables = self.get_tables(conn)
        add_layer(path_file, res_tables)
        self.open_fenetre2(conn,db)

#une fenêtre Windows s'ouvre pour spécifier le nom du fichier et la localisation de l'enregistrement.
def creer_nouvelle_base(self):
    path_file = self.save_output_file()
    if path_file!="":
        #On informe l'utilisateur que l'action est en cours
        #self.iface.messageBar().pushMessage("Information", "La création est en cours", level=Qgis.Info, duration=4)
        #
        res_tables=create_bdd(path_file)
        conn = connexion_bdd(path_file)
        db = connexion_sqldb(path_file)
        #On récupère le nom des tables présent dans la bdd, afin les chargers
        res_tables = self.get_tables(conn)
        #On charges les couches geométrique
        add_layer(path_file,res_tables)
        #On appelle la fenetre suivante
        self.open_fenetre2(conn,db)

#Permet de selectionner un fichier
def open_output_file(self):
    filename, _filter = QFileDialog.getOpenFileName(
        self, "Selectionner un fichier","", '*.sqlite')
    #retoune le chemin du fichier
    return filename

#Permet de selectionner un fichier
def save_output_file(self):
    filename, _filter = QFileDialog.getSaveFileName(
        self, "Selectionner un fichier","", '*.sqlite')
    #retoune le chemin du fichier
    return filename

#Permet d'ouvrir la fenetre 2
def open_fenetre2(self, conn,db):
    self.fenetre2 = DialogBADASSForm2( self.iface, conn,db)
    # show the dialog
    self.fenetre2.show()

#Extension OTD
def extensions_otd(self):
    #On regarde si l'extention est coché
    self.decoche_information(self.Ajout_Extension_OTD)

#Extension bati
def extensions_bati(self):
    #On regarde si l'extention est coché
    self.decoche_information(self.Extension_bati)

#Message d'information si une case est décoché
def decoche_information(self,name_qcheckbox):
    if not name_qcheckbox.isChecked():
        msgBox = QMessageBox()
        msgBox.setIcon(QMessageBox.Information)
        msgBox.setWindowTitle("Information !")
        msgBox.setText("Désactiver cette extension supprimera les données enregistrées dans\nces contextes ! Êtes-vous sûr.e devouloir supprimer cette extension ?")
        msgBox.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
        #msgBox.buttonClicked.connect(msgButtonClick)

        returnValue = msgBox.exec()
        if returnValue == QMessageBox.Ok:
            print('Suppression confirmé')

def get_tables(self,conn):
    #Cette méthode permet de récuperer les noms des tables
    #Les tables géometrique sont récuperer avec la méthode suivantes :
    geom_tables=self.get_geom_tables(conn)
    #Toutes les tables sont récupèrer avec la méthode suivantes :
    all_tables=self.get_all_tables_name(conn)
    #Etape intermédiaire, on place les noms de couches dans un tableau
    tab_inter=[]
    for element in geom_tables:
        tab_inter.append(element[0])
    #On ajoute les tables manquantes dans le tableau geom avec comme nom de colonne geom 'None'
    for element in all_tables:
        if element not in tab_inter:
            geom_tables.append([element, None])
    return geom_tables


def get_geom_tables(self,conn):
    try:
        self.conn = conn
        self.cur = conn.cursor()
        #SQL recup les nom de tables:
        cur = conn.cursor()
        sql="SELECT f_table_name, f_geometry_column from geometry_columns;"
        cur.execute(sql)
        res_tables=(cur.fetchall())
        #

        cur.close()
    except Exception as e:
        print("erreur")
    return res_tables

def get_all_tables_name(self,conn):
    try:
        self.conn = conn
        self.cur = conn.cursor()
        #SQL recup les nom de tables:
        cur = conn.cursor()
        sql="SELECT name FROM sqlite_master WHERE type='table';"
        cur.execute(sql)
        res_tables=(cur.fetchall())
        all_tables=[]
        metadata=True
        for element in res_tables:
            if not metadata:
                all_tables.append(element[0])
            if element[0]=='ElementaryGeometries':
                metadata=False
        #
        cur.close()
    except Exception as e:
        print("erreur")
    return all_tables


#add layer with fournisseur_donnees_memoire ="spatialite"
def add_layer(path_file, res_tables):
    for element in res_tables:
        uri = QgsDataSourceUri()
        uri.setDatabase(path_file)
        schema = ''
        table = element[0]
        geom_column = element[1]
        uri.setDataSource(schema, table, geom_column)
        layer_name = table
        layer = QgsVectorLayer(uri.uri(), layer_name, 'spatialite')
        QgsProject.instance().addMapLayer(layer)
