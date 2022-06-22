"""
Contient des fonctions diverses.
"""

from qgis.PyQt import QtWidgets 

def exec_tasks(tasks: list, bar: QtWidgets.QProgressBar):
    """
    Exécute une liste de tâche asynchrone en mettant à jour la progress bar.
    Args:
        tasks (list): Liste des lambda à exécuter
        bar (QtWidgets.QProgressBar): Bar de progression à mettre à jour
    """
    total = len(tasks)
    i = 0
    for task in tasks:
        task()
        i += 1
        bar.setValue((i*100)//total)
