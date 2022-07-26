"""
Contient des fonctions diverses.
"""
from qgis.core import QgsMessageLog

def log(msg):
    """
    Affiche un message dans le log de QGIS.
    """
    QgsMessageLog.logMessage(msg, "badass")

def copy_str(text: str):
    """
    Créer une copie indépendate du str.
    
    Returns:
        str: Copie
    """
    return (text + '.')[:-1]

def split_sql(content: str):
    """
    Sépare un script SQL en sous-requêtes.
    """
    comment = False
    comment_s = False # Lecture d'un commentaire sur une ligne
    comment_l = False # Lecture d'un commentaire sur plusieurs lignes
    last_split_i = 0
    checking_end = False
    waiting_end_semicolon = False
    statements = []
    for i in range(len(content)):
        char = content[i]
        char2 = content[i:i+2]
        if char == " " or char == "\t": continue

        # Gestion commentaire
        if not comment and char2 == "--":
            comment_s = True
            comment = True
            continue
        if not comment and char2 == "/*":
            comment_l = True
            comment = True
            continue
        if comment_s and char == "\n" :
            comment_s = False
            comment = False
            continue
        if comment_l and content[i-1:i+1] == "*/":
            comment_l = False
            comment = False
            continue
        if char == "\n": continue

        # Vérification transaction en cours
        if not comment and not checking_end and content[i:i+5] == "BEGIN":
            checking_end = True
            continue
        if not comment and checking_end and content[i:i+3] == "END":
            checking_end = False
            continue

        # Séparation de la requête
        if not comment and not checking_end and char == ";":
            statements.append(content[last_split_i:i+1])
            last_split_i = i+1
            continue

    # Ajout dernière requête
    statements.append(content[last_split_i:len(content)])

    return statements
