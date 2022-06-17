from qgis.core import *
from qgis.PyQt.QtCore import QVariant



#add layer with fournisseur_donnees_memoire ="spatialite"
def add_layer(path_file, res_tables):
    for element in res_tables:
        uri = QgsDataSourceUri()
        uri.setDatabase(path_file)
        schema = ''
        table = element[0]
        geom_column = element[1]
        uri.setDataSource(schema, table, geom_column)
        layer_name = table
        layer = QgsVectorLayer(uri.uri(), layer_name, 'spatialite')
        QgsProject.instance().addMapLayer(layer)
