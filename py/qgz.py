"""
Module d'édition d'un fichier QGZ
"""

from qgis.core import QgsMessageLog

import os
import shutil
from zipfile import ZipFile
from . import files

ORGINAL_DB_NAME = "badass_v2_vierge.sqlite"

def create_qgz(dest_path: str):
    """
    Permet de créer un nouveau fichier QGZ au chemin indiqué.
    Args:
        dest_path (str): Chemin du nouveau fichier QGZ.
    """
    src_path = files.get_file_path("file/model.qgz")
    
    shutil.copyfile(src_path, dest_path)

def __edit_qgz_db(path: str, new_db_name: str, old_db_name: str = ORGINAL_DB_NAME):
    """
    Modifie le nom de la base de données dans le projet qgis.

    Args:
        path (str): Chemin du fichier .qgz
        new_db_name (str): Nom de la nouvelle base de données
        old_db_name (str): Ancien nom de la bdd à remplacer
    """
    
    dir_path = os.path.dirname(path)
    files = []

    with ZipFile(path, "r") as src_zip:
        # Extraction du fichier qgz
        src_zip.extractall(dir_path)
        files = src_zip.filelist
    
    # Récupération nom du fichier qgs
    qgs_path = ""
    for file in files:
        if ".qgs" in file.filename:
            qgs_path = os.path.join(dir_path, file.filename)

    # Remplacement ancien nom de la bdd
    text = ""
    with open(qgs_path, "r") as qgs_file:
        text = qgs_file.read()
        text = text.replace(old_db_name, new_db_name)
    with open(qgs_path, "w") as qgs_file:
        qgs_file.write(text)

    # Compression avec le qgs modifié
    os.remove(path)
    with ZipFile(path, "w") as dest_zip:
        for file in files:
            dest_zip.write(os.path.join(dir_path, file.filename))
    
    # Suppression des fichiers inutiles
    for file in files:
        os.remove(os.path.join(dir_path, file.filename))