# -*- coding: utf-8 -*-
import os
import sqlite3
import sqlite3 as lite
from PyQt5.QtSql import QSqlDatabase
#On import les class pour l'intansiation des autres fenetre


class DB:
    """
    Facilite la création et gestion d'une base de données sqlite.
    """
    #https://www.opensourceforu.com/2016/10/file-search-with-python/
    def create_bdd(bdd_path):
        conn = sqlite3.connect(bdd_path)
        cur = conn.cursor()
        #Création de la table
        #ajout de l'extension mod_spatialite sinon la fonction AddGeometryColumn n'est pas reconnue
        conn.enable_load_extension(True)
        sql="SELECT load_extension('mod_spatialite')"
        conn.execute(sql)
        #Ajout les tables de métadonnées spatiales
        """si l'argument optionnel transaction est défini sur TRUE,
        toute l'opération sera traitée comme une seule transaction (plus rapide)
        le paramètre par défaut est transaction = FALSE (plus lent, mais plus sûr)
        http://www.gaia-gis.it/gaia-sins/spatialite-sql-latest.html"""
        sql="SELECT InitSpatialMetaData(1)"
        cur.execute(sql)
        #Permet de récuperer le nom du fichier qui créer le code sql
        path_sql_file=helper.get_file_path('sql_create_code.sql')

        #Execute le code sql
        with open(path_sql_file, "r", encoding="utf-8") as sql_file:
            sql_code = sql_file.read()
            #On execute le code sql
            cur.executescript(sql_code)
        #Fermeture de la connexion
        cur.close()
        conn.close()

    def connexion_bdd(bdd_path):
        try:
            #
            conn = sqlite3.connect(bdd_path)
            #On charge le mode spatiale également lors de la connexion
            conn.enable_load_extension(True)
            sql='SELECT load_extension("mod_spatialite")'
            conn.execute(sql)
            #
            return conn
        except Exception as e:
            raise

    #Cette connexion permet de utliser le model sql avec les QTableView
    def connexion_sqldb(path_file):
        #
        db = QSqlDatabase.addDatabase("QSQLITE")
        db.setDatabaseName(path_file)
        return db


    def get_name_colonne(cur,colonne_name):
        try:
            sql = "PRAGMA table_info("+colonne_name+");"
            cur.execute(sql)
            res=cur.fetchall()
            colonne_names=[]
            for element in res:
                colonne_names.append(element[1])
            return colonne_names
        except Exception as e:
            raise
