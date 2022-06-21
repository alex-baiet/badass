# -*- coding: utf-8 -*-
import os
import sqlite3
from PyQt5.QtSql import QSqlDatabase
from . import helper
#On import les class pour l'intansiation des autres fenetre

"""
Facilite la création et gestion d'une base de données sqlite.
"""

#https://www.opensourceforu.com/2016/10/file-search-with-python/
def create_bdd(db_path: str):
    """Crée une nouvelle base de données au chemin indiqué sans extension."""
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # Ajout de l'extension mod_spatialite sinon la fonction AddGeometryColumn n'est pas reconnue
    conn.enable_load_extension(True)
    sql = "SELECT load_extension('mod_spatialite')"
    conn.execute(sql)
    
    # Ajout les tables de métadonnées spatiales
    sql = "SELECT InitSpatialMetaData(1)"
    cur.execute(sql)
    
    # Récupération code SQL
    path_sql_file = helper.get_file_path('file/sql/main_structure.sql')
    with open(path_sql_file, "r", encoding="utf-8") as sql_file:
        sql_code = sql_file.read()        
        # Création bdd
        cur.executescript(sql_code)

    #Fermeture de la connexion
    cur.close()
    conn.close()

def add_of_the_dead_ext(db_path: str):
    """Ajoute l'extension Of The Dead à la base de données du chemin."""    
    __exec_sql(db_path, helper.get_file_path('file/sql/of_the_dead.sql'))

def add_at_home_ext(db_path: str):
    """Ajoute l'extension At Home à la base de données du chemin. Le fichier SQL nécessaire n'existe pas encore..."""    
    __exec_sql(db_path, helper.get_file_path('file/sql/at_home.sql'))

def __exec_sql(db_path: str, sql_path: str):
    """
    Exécute un script SQL dans la base de données du chemin indiqué.
    Args:
        db_path (str): Chemin de la base de données
        ext_path (str): Chemin du script d'extension au format SQL
    """
    if not os.path.exists(db_path):
        raise IOError("La base de données n'existe pas au chemin \""+db_path+"\"")
    
    # Ouverture connexion
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # Ajout de l'extension mod_spatialite sinon la fonction AddGeometryColumn n'est pas reconnue
    conn.enable_load_extension(True)
    sql = "SELECT load_extension('mod_spatialite')"
    conn.execute(sql)
    
    # Ajout des tables de métadonnées spatiales
    sql = "SELECT InitSpatialMetaData(1)"
    cur.execute(sql)
    
    # Récupération code SQL
    path_sql_file = sql_path
    with open(path_sql_file, "r", encoding="utf-8") as sql_file:
        sql_code = sql_file.read()        
        # Création bdd
        cur.executescript(sql_code)

    # Fermeture connexion
    cur.close()
    conn.close()

def connect_db(db_path):
    conn = sqlite3.connect(db_path)
    # On charge le mode spatiale également lors de la connexion
    conn.enable_load_extension(True)
    sql='SELECT load_extension("mod_spatialite")'
    conn.execute(sql)
    return conn

def connect_db_qt(db_path):
    """Cette connexion permet de utliser le model sql avec les QTableView"""
    db = QSqlDatabase.addDatabase("QSQLITE")
    db.setDatabaseName(db_path)
    return db