# -*- coding: utf-8 -*-
"""
Layer Solo Nav - Krita Plugin

Presentation-style layer navigation for Krita.
Provides solo visibility mode where only the active layer and background are visible.

Features:
- Layer Down: Navigate to next layer down (solo mode)
- Layer Up: Navigate to next layer up or create new layer (solo mode)
- Background layer always remains visible
- Auto-creates new layers when navigating past the top
"""

from krita import *

PARASITE_NAME = "layer_solo_nav_slide_count"


def get_layer_counter(doc):
    """Get the slide counter from document metadata."""
    try:
        info = doc.annotation(PARASITE_NAME)
        if info:
            return int(info)
    except:
        pass
    return 2


def set_layer_counter(doc, value):
    """Set the slide counter in document metadata."""
    try:
        doc.setAnnotation(PARASITE_NAME, str(value))
    except:
        pass


def get_all_layers(node, layer_list=None):
    """Recursively get all layer nodes from the document."""
    if layer_list is None:
        layer_list = []
    
    if node.type() in ['paintlayer', 'grouplayer', 'vectorlayer', 'filelayer', 'clonelayer', 'filterlayer', 'filllayer', 'patternlayer']:
        layer_list.append(node)
    
    for child in node.childNodes():
        get_all_layers(child, layer_list)
    
    return layer_list


def get_root_layers(doc):
    """Get top-level layers (root nodes) in order from top to bottom."""
    root = doc.rootNode()
    return [child for child in root.childNodes()]


class LayerSoloNav(Extension):
    def __init__(self, parent):
        super().__init__(parent)

    def setup(self):
        pass

    def createActions(self, window):
        action = window.createAction("layer_down_solo", "Layer Down (Solo Prev)")
        action.triggered.connect(self.layer_down_solo)
        
        action = window.createAction("layer_up_solo", "Layer Up (Solo Next or New)")
        action.triggered.connect(self.layer_up_solo)

    def get_active_doc(self):
        """Get the currently active document."""
        app = Krita.instance()
        return app.activeDocument()

    def get_active_layer(self, doc):
        """Get the currently active layer/node."""
        return doc.activeNode()

    def get_background_layer(self, layers):
        """Get the bottom-most layer as background."""
        if not layers:
            return None
        return layers[-1]

    def layer_down_solo(self):
        """Navigate to the next layer down in solo mode."""
        doc = self.get_active_doc()
        if not doc:
            return

        doc.startUndoMacro("Layer Down Solo")
        
        try:
            root_layers = get_root_layers(doc)
            if not root_layers:
                doc.endUndoMacro()
                return

            active = self.get_active_layer(doc)
            background = self.get_background_layer(root_layers)

            # Make background visible
            if background:
                background.setVisible(True)

            if active and active in root_layers:
                active_index = root_layers.index(active)
                # Check if we can move down (layers are in reverse order in Krita)
                # Index 0 is top, index -1 is bottom (background)
                if active_index + 1 < len(root_layers) - 1:  # Don't go past background
                    new_active = root_layers[active_index + 1]
                    doc.setActiveNode(new_active)

                    # Solo mode: only new active and background visible
                    for layer in root_layers:
                        if layer == new_active or layer == background:
                            layer.setVisible(True)
                        else:
                            layer.setVisible(False)

            doc.refreshProjection()
        finally:
            doc.endUndoMacro()

    def layer_up_solo(self):
        """Navigate to the next layer up or create a new layer in solo mode."""
        doc = self.get_active_doc()
        if not doc:
            return

        doc.startUndoMacro("Layer Up Solo")
        
        try:
            root_layers = get_root_layers(doc)
            if not root_layers:
                doc.endUndoMacro()
                return

            active = self.get_active_layer(doc)
            background = self.get_background_layer(root_layers)

            # Make background visible
            if background:
                background.setVisible(True)

            if active and active in root_layers:
                active_index = root_layers.index(active)
            else:
                active_index = None

            # If we're not at the top (index 0), move up
            if active_index is not None and active_index > 0:
                new_active = root_layers[active_index - 1]
            else:
                # Create a new layer at the top
                slide_num = get_layer_counter(doc)
                new_active = doc.createNode(f"Slide {slide_num}", "paintlayer")
                new_active.setVisible(True)
                root = doc.rootNode()
                root.addChildNode(new_active, root_layers[0] if root_layers else None)
                set_layer_counter(doc, slide_num + 1)

            doc.setActiveNode(new_active)

            # Solo mode: only new active and background visible
            for layer in root_layers:
                if layer == new_active or layer == background:
                    layer.setVisible(True)
                else:
                    layer.setVisible(False)

            doc.refreshProjection()
        finally:
            doc.endUndoMacro()


# Register the extension
Krita.instance().addExtension(LayerSoloNav(Krita.instance()))
