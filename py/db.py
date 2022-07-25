# -*- coding: utf-8 -*-
import os
import sqlite3
from PyQt5.QtSql import QSqlDatabase
from qgis.PyQt import QtWidgets
from qgis.core import QgsMessageLog
from . import files
from . import process
from . import helper
#On import les class pour l'intansiation des autres fenetre

"""
Facilite la création et gestion d'une base de données sqlite.
"""

SQL_MAIN = files.get_file_path('file/sql/main_structure.sql')
SQL_OF_THE_DEAD = files.get_file_path('file/sql/of_the_dead.sql')
SQL_AT_HOME = files.get_file_path('file/sql/at_home.sql')

SQL_SEPARATOR = "/*--*/"

def exec_sql_file(db_path: str, sql_path: str):
    """
    Exécute un script SQL dans la base de données du chemin indiqué.
    Args:
        db_path (str): Chemin de la base de données
        ext_path (str): Chemin du script d'extension au format SQL
    """
    conn, cur = connect_db(db_path)
    
    # Récupération code SQL
    path_sql_file = sql_path
    with open(path_sql_file, "r", encoding="utf-8") as sql_file:
        sql_code = sql_file.read()
        # Création bdd
        cur.executescript(sql_code)

    # Fermeture connexion
    cur.close()
    conn.close()
    
def generate_sql_tasks(db_path: str, sql_path: str): 
    """
    Génère une liste de lambda pour exécuter le fichier de sql_path part à part.
    Args:
        db_path (str): Chemin de la base de données
        ext_path (str): Chemin du script d'extension au format SQL
        
    Returns:
        list: Liste des différentes tâches pour exécuter tout le script SQL.
    """
    global conn, cur
    tasks = []
    # Ouverture connexion
    tasks.append(lambda: __init_exec_sql(db_path))
    
    # Récupération code SQL
    with open(sql_path, "r", encoding="utf-8") as sql_file:
        sql_code = sql_file.read()
        # sql_parts = sql_code.split(SQL_SEPARATOR)
        sql_parts = helper.split_sql(sql_code)
        for part in sql_parts:
            # Exécution d'une partie du SQL
            tasks.append(lambda part=part: __exec_sql_part(part))

    # Fermeture connexion
    tasks.append(__close_exec_sql)
    return tasks

#region Lamdbas
def __init_exec_sql(db_path: str):
    global conn, cur
    conn, cur = connect_db(db_path)
    
def __exec_sql_part(sql: str):
    global cur
    cur.executescript(sql)

def __close_exec_sql():
    global conn, cur
    cur.close()
    conn.close()
#endregion

def connect_db(db_path: str) -> [sqlite3.Connection, sqlite3.Cursor]:
    """
    Se connecte à la bdd et retourne de quoi l'éditer.
    Args:
        db_path (str): Chemin de la base de données
    Returns:
        [sqlite3.Connection, sqlite3.Cursor]: Accès à la bdd
    """
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # Ajout de l'extension mod_spatialite sinon la fonction AddGeometryColumn n'est pas reconnue
    conn.enable_load_extension(True)
    sql = "SELECT load_extension('mod_spatialite')"
    conn.execute(sql)

    # Ajout des tables de métadonnées spatiales
    sql = "SELECT InitSpatialMetaData(1)"
    cur.execute(sql)

    return conn, cur

def connect_db_qt(db_path):
    """Cette connexion permet de utliser le model sql avec les QTableView"""
    db = QSqlDatabase.addDatabase("QSQLITE")
    db.setDatabaseName(db_path)
    return db

################
# Fonctions de requetes sql non fonctionnels
################

def exec_sql_files_async(db_path: str, sql_paths: list, bar: QtWidgets.QProgressBar):
    """
    Exécute les requêtes SQL des fichiers données asynchronement.
    Si la bdd n'existe pas, elle sera créé.
    Args:
        db_path (str): Fichier de la bdd
        sql_paths (list): Liste des fichiers sql à exécuter
        bar (QtWidgets.QProgressBar): Barre de progression à mettre à jour.
    """
    # Connexion à la bdd
    conn, cur = connect_db(db_path)

    # Récupération code SQL
    tasks = []
    for path in sql_paths:
        with open(path, "r", encoding="utf-8") as sql_file:
            sql_code = sql_file.read()
            tasks.append(lambda: __exec_sql(sql_code, cur))
    tasks.append(lambda: __close(conn, cur))
    
    # Exécution du code
    process.exec_tasks(tasks, bar)

def __close(conn: sqlite3.Connection, cur: sqlite3.Cursor):
    cur.close()
    conn.close()
    
def __exec_sql(sql: str, cur: sqlite3.Cursor):
    """Exécute un script SQL."""
    try:
        cur.execute(sql)
    except sqlite3.OperationalError:
        raise Exception("Une erreur est survenu avec la requete suivante : '"+sql+"'")
