"""
Module d'édition d'un fichier QGZ
"""

import shutil
from zipfile import ZipFile
from . import helper

def create_qgz(dest_path: str):
    """
    Permet de créer un nouveau fichier QGZ au chemin indiqué.
    Args:
        dest_path (str): Chemin du nouveau fichier QGZ.
    """
    src_path = helper.get_file_path("file/model.qgz")
    
    shutil.copyfile(src_path, dest_path)
    