import re
from qgis.core import QgsApplication
import os

def get_file_path(name_file):
    path_profil=QgsApplication.qgisSettingsDirPath()
    #path_file=path_profil+'python\plugins\dialog_badass\\'+name_file
    path_file=os.path.dirname(os.path.realpath(__file__))+ os.path.sep + name_file
    return path_file


#Cette fonction permet de récupérer les noms de tables spatiale, afin d'ajouter des couches seulement pour les tables spatiales
def recup_tables_spatiales(sql_code):
    try:
        res_tables=[]
        #CREATE TABLE ([a-z_]*)\((\n {3}[1-9a-z"\'\_A-Z ,\n\(\)-]*);\nSELECT\nAddGeometryColumn
        regex = re.compile(r'CREATE TABLE ([a-z_]*)\(([^;]*);\nSELECT\nAddGeometryColumn')
        res_regex_tables = regex.findall(sql_code)
        for element in res_regex_tables:
            res_tables.append(element[0])
        return res_tables
    except Exception as e:
        raise
