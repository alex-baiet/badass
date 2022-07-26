"""
Contient des fonctions diverses.
"""
from qgis.core import QgsMessageLog

def log(msg):
    """
    Affiche un message dans le log de QGIS.
    """
    QgsMessageLog.logMessage(msg, "badass")
