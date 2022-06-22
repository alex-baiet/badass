import re
from qgis.PyQt.QtGui import QPixmap
from qgis.PyQt.QtWidgets import QFileDialog, QLineEdit
from qgis.core import QgsApplication, QgsMessageLog
import os

"""
Contient des fonctions aux utilités très diverses.
... mais actuellement plutôt orientées autour de la gestion de fichiers.
"""

def get_file_path(filename) -> str:
    """
    Renvoie le chemin absolue du fichier.
    Args:
        filname (str): Nom du chemin relatif du fichier
    Returns:
        str: Chemin absolue
    """
    return os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), filename)

def get_plugin_file_path(filename) -> str:
    """
    Renvoie le chemin du fichier avec la notation de QGIS.
    Args:
        filename (str): Nom du chemin relatif à la racine du plugin
    Returns:
        str: Chemin selon la notation de QGIS
    """
    return ":/plugins/badass/"+filename

def load_pixmap(filename: str) -> QPixmap:
    """Charge un QPixmap depuis un fichier. Permet d'afficher une image dans un label par exemple."""
    # pixmap_o = QPixmap(':/plugins/dialog_badass/BADASS_logo_full.png')
    pixmap_o = QPixmap(get_file_path(filename))
    # pixmap_o = QPixmap(get_plugin_file_path(filename))
    w=pixmap_o.width()/40
    h=pixmap_o.height()/40
    pixmap = pixmap_o.scaled(w, h)
    return pixmap

def save_output_file(title: str, filter: str):
    """
    Permet de sélectionner un chemin de fichier à créer.
    Args:
        title (str): Titre du popup
        filter (str): Filtre des fichiers (exemple: "Texte (*.txt)"
    """
    filename, _filter = QFileDialog.getSaveFileName(caption=title, filter=filter)
    return filename

def open_output_file(title: str, filter: str):
    """
    Permet de sélectionner un chemin de fichier existant.
    Args:
        title (str): Titre du popup
        filter (str): Filtre des fichiers (exemple: "Texte (*.txt)"
    """
    filename, _filter = QFileDialog.getOpenFileName(caption=title, filter=filter)
    #retoune le chemin du fichier
    return filename

def save_output_dir(title: str):
    """
    Permet de sélectionner un chemin de dossier existant.
    Args:
        title (str): Titre du popup
    """
    filename, _filter = QFileDialog.getExistingDirectory(caption=title)
    #retoune le chemin du fichier
    return filename

def select_file_to_lineedit(title: str, filter: str, fileend: str, lineedit: QLineEdit):
    """
    Permet de sélectionner un chemin pour un nouveau fichier, et de le mettre dans le lineedit.
    Args:
        title (str): Titre du popup
        filter (str): Filtre des fichiers (exemple: "Texte (*.txt)"
        fileend (str): Terminaison du fichier
        lineedit (QLineEdit): QLineEdit à remplir
    """
    filename, filt = QFileDialog.getSaveFileName(caption=title, filter=filter)
    if len(filename) > 0:
        if not filename.endswith(fileend):
            filename += fileend
        lineedit.setText(filename)

def open_file_to_lineedit(title: str, filter: str, lineedit: QLineEdit):
    """
    Permet de sélectionner un chemin pour un fichier existant, et de le mettre dans le lineedit.
    Args:
        title (str): Titre du popup
        filter (str): Filtre des fichiers (exemple: "Texte (*.txt)"
        lineedit (QLineEdit): QLineEdit à remplir
    """
    filename, filt = QFileDialog.getOpenFileName(caption=title, filter=filter)
    if len(filename) > 0:
        lineedit.setText(filename)

def save_dir_to_lineedit(title: str, lineedit: QLineEdit):
    """
    Permet de sélectionner un chemin pour un fichier existant, et de le mettre dans le lineedit.
    Args:
        title (str): Titre du popup
        lineedit (QLineEdit): QLineEdit à remplir
    """
    dirname = QFileDialog.getExistingDirectory(caption=title)
    if len(dirname) > 0:
        lineedit.setText(dirname)
