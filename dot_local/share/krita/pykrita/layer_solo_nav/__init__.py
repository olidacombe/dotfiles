# -*- coding: utf-8 -*-
"""
Layer Solo Nav - Krita Plugin

Navigation by position (index):
- Layer Up: move to higher index (away from background, deeper in stack)
- Layer Down: move to lower index (toward background)
- At highest index + Up: create new slide at bottom
- At index 1 + Down: do nothing
- Background (index 0) is never selected
"""

from krita import *

DEBUG = False


def log(msg):
    if DEBUG:
        print(f"[LAYER_SOLO_NAV] {msg}")


def get_max_slide_number(doc):
    """Find the highest slide number for naming new slides."""
    root = doc.rootNode()
    max_num = 0

    for child in root.childNodes():
        name = child.name()
        if name.startswith("Slide "):
            try:
                num = int(name.split()[1])
                max_num = max(max_num, num)
            except (IndexError, ValueError):
                pass

    return max_num


def get_background_layer(doc):
    """Get the background layer (index 0, topmost)."""
    root = doc.rootNode()
    layers = [child for child in root.childNodes()]
    return layers[0] if layers else None


def log_layers(doc, title="Layers"):
    """Log current layer state."""
    root = doc.rootNode()
    layers = [child for child in root.childNodes()]
    log(f"{title} (top to bottom):")
    for i, lyr in enumerate(layers):
        log(f"  [{i}] {lyr.name()}")


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

    def layer_down_solo(self):
        """Move DOWN = toward background (lower index)."""
        log("\n=== LAYER DOWN ===")
        doc = Krita.instance().activeDocument()
        if not doc:
            log("ERROR: No document")
            return

        active = doc.activeNode()
        if not active:
            log("ERROR: No active layer")
            return

        background = get_background_layer(doc)
        if active == background:
            log("Background is selected, nothing to do")
            return

        # Get all layers
        root = doc.rootNode()
        all_layers = [child for child in root.childNodes()]

        try:
            active_index = all_layers.index(active)
        except ValueError:
            log("Active layer not in root")
            return

        log(f"Active: {active.name()} at index {active_index}")
        log_layers(doc, "Before")

        # Move DOWN = lower index (toward background)
        # Stop at index 1 (can't go to index 0 which is background)
        if active_index > 1:
            new_active = all_layers[active_index - 1]
            log(f"Moving DOWN to: {new_active.name()}")

            doc.setActiveNode(new_active)

            # Solo visibility: active + background
            for layer in all_layers:
                layer.setVisible(layer == new_active or layer == background)

            doc.refreshProjection()
        else:
            log("Already at index 1, doing nothing")

    def layer_up_solo(self):
        """Move UP = away from background (higher index), or create new if at bottom."""
        log("\n=== LAYER UP ===")
        doc = Krita.instance().activeDocument()
        if not doc:
            log("ERROR: No document")
            return

        active = doc.activeNode()
        background = get_background_layer(doc)

        # Get all layers
        root = doc.rootNode()
        all_layers = [child for child in root.childNodes()]

        if not active:
            log("No active layer, will create new at bottom")
            active_index = None
        else:
            try:
                active_index = all_layers.index(active)
                log(f"Active: {active.name()} at index {active_index}")
            except ValueError:
                log("Active layer not in root, will create new at bottom")
                active_index = None

        log_layers(doc, "Before")

        # If at bottom (highest index) or no active, create new slide at bottom
        if active_index is None or active_index >= len(all_layers) - 1:
            # Create new slide at the bottom (highest index)
            new_num = get_max_slide_number(doc) + 1
            new_name = f"Slide {new_num}"
            log(f"Creating new layer: {new_name} at bottom")

            new_layer = doc.createNode(new_name, "paintlayer")
            new_layer.setVisible(True)

            # Add at bottom (no position = append at end)
            root.addChildNode(new_layer, None)

            doc.setActiveNode(new_layer)
            target = new_layer

            # Refresh layer list
            all_layers = [child for child in root.childNodes()]
        else:
            # Move UP to higher index
            new_active = all_layers[active_index + 1]
            log(f"Moving UP to: {new_active.name()}")

            doc.setActiveNode(new_active)
            target = new_active

        # Solo visibility: active + background
        for layer in all_layers:
            layer.setVisible(layer == target or layer == background)

        doc.refreshProjection()
        log(f"Now on: {target.name()}")


Krita.instance().addExtension(LayerSoloNav(Krita.instance()))
