#https://qgis.org/pyqgis/master/
#https://qgis.org/pyqgis/3.2/gui/Expression/QgsExpressionBuilderDialog.html
from qgis.gui import QgsExpressionBuilderDialog
from qgis.utils import iface

def expression_dialog(self,iface):
    layer = iface.activeLayer()
    self.expression_builder_dialog = QgsExpressionBuilderDialog(layer)
    self.expression_builder_dialog.show()
