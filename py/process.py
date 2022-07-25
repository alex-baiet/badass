"""
Permet de réaliser des actions asynchrone.
"""

from qgis.PyQt.QtWidgets import QProgressBar
from qgis.PyQt.QtCore import QTimer

__timer = QTimer()

def exec_tasks(tasks: list, bar: QProgressBar):
    """
    Exécute une liste de tâches asynchrones en mettant à jour la progress bar.
    Args:
        tasks (list): Liste des lambda à exécuter
        bar (QProgressBar): Bar de progression à mettre à jour
    """
    __timer.singleShot(0, lambda: __exec_tasks_rec(tasks, bar, 0))

def __exec_tasks_rec(tasks: list, bar: QProgressBar, __i: int = 0):
    if len(tasks) <= __i:
        return # Toutes les tâches ont été exécutées
    
    task = tasks[__i]
    task()
    if bar is not None: bar.setValue(((__i+1)*100)//len(tasks))
    __timer.singleShot(0, lambda: __exec_tasks_rec(tasks, bar, __i+1))
