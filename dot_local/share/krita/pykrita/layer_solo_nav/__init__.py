# -*- coding: utf-8 -*-
"""
Layer Solo Nav - Krita Plugin

Krita layer order: Index 0 = top of stack (visually on top), Index -1 = bottom
"""

from krita import *

DEBUG = True


def log(msg):
    if DEBUG:
        print(f"[LAYER_SOLO_NAV] {msg}")


def get_next_slide_number(doc):
    """Find the highest existing slide number and return next."""
    root = doc.rootNode()
    max_num = 1

    for child in root.childNodes():
        name = child.name()
        if name.startswith("Slide "):
            try:
                num = int(name.split()[1])
                max_num = max(max_num, num)
            except (IndexError, ValueError):
                pass

    return max_num + 1


def get_root_layers(doc):
    """Get layers from top (index 0) to bottom (index -1)."""
    root = doc.rootNode()
    layers = [child for child in root.childNodes()]
    log(f"Root layers (top to bottom):")
    for i, lyr in enumerate(layers):
        log(f"  [{i}] {lyr.name()}")
    return layers


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

    def get_background_layer(self, layers):
        """Background is the first/top layer (index 0)."""
        return layers[0] if layers else None

    def layer_down_solo(self):
        """Move DOWN the layer stack (toward bottom, higher index)."""
        log("\n=== LAYER DOWN ===")
        doc = Krita.instance().activeDocument()
        if not doc:
            log("ERROR: No document!")
            return

        active = doc.activeNode()
        if not active:
            log("ERROR: No active layer")
            return

        root_layers = get_root_layers(doc)
        if len(root_layers) < 2:
            log("Need more layers")
            return

        background = self.get_background_layer(root_layers)
        log(f"Background: {background.name()}")

        try:
            active_index = root_layers.index(active)
        except ValueError:
            log(f"Active layer not in root")
            return

        log(f"Active: {active.name()} at index {active_index}")

        # Move down = higher index
        if active_index < len(root_layers) - 1:
            new_active = root_layers[active_index + 1]

            # Don't select background layer
            if new_active == background:
                log("Can't go below background")
                return

            log(f"Moving to: {new_active.name()}")
            doc.setActiveNode(new_active)

            # Solo visibility
            for layer in root_layers:
                layer.setVisible(layer == new_active or layer == background)

            doc.refreshProjection()
        else:
            log("Already at bottom")

    def layer_up_solo(self):
        """Move UP or create new layer."""
        log("\n=== LAYER UP ===")
        doc = Krita.instance().activeDocument()
        if not doc:
            log("ERROR: No document!")
            return

        active = doc.activeNode()
        root_layers = get_root_layers(doc)

        if not root_layers:
            log("ERROR: No layers")
            return

        background = self.get_background_layer(root_layers)
        log(f"Background: {background.name()}")

        # Get active layer index
        active_index = None
        if active:
            try:
                active_index = root_layers.index(active)
                log(f"Active: {active.name()} at index {active_index}")
            except ValueError:
                log("Active not in root layers")

        # If at background or just below it, create new slide
        if active_index is None or active_index <= 1:
            # Create new slide layer
            slide_num = get_next_slide_number(doc)
            new_name = f"Slide {slide_num}"
            log(f"Creating new layer: {new_name}")

            new_layer = doc.createNode(new_name, "paintlayer")
            new_layer.setVisible(True)

            # Add to root - this puts it at the bottom (highest index)
            root = doc.rootNode()
            root.addChildNode(new_layer, None)

            # Now we need to move it to just below background (index 1)
            # In Krita, we need to move it UP in the stack (toward lower index)
            # to position it right after background

            # Get fresh layer list
            fresh_layers = get_root_layers(doc)
            new_layer_idx = None
            for i, lyr in enumerate(fresh_layers):
                if lyr == new_layer:
                    new_layer_idx = i
                    break

            if new_layer_idx is not None and new_layer_idx > 1:
                log(f"Moving new layer from index {new_layer_idx} to position 1")
                # Move up repeatedly until we're at index 1
                for _ in range(new_layer_idx - 1):
                    # Move up in Krita means moving toward lower index
                    # We use the layer's move functionality if available
                    pass  # Layer positioning is tricky, let's try another approach

            new_active = new_layer

            # Refresh layer list
            root_layers = get_root_layers(doc)
        else:
            # Move up to lower index (toward top)
            new_active = root_layers[active_index - 1]

            if new_active == background:
                # Create new instead of selecting background
                slide_num = get_next_slide_number(doc)
                new_name = f"Slide {slide_num}"
                log(f"Would hit background, creating: {new_name}")

                new_layer = doc.createNode(new_name, "paintlayer")
                new_layer.setVisible(True)
                root = doc.rootNode()
                root.addChildNode(new_layer, None)
                new_active = new_layer
                root_layers = get_root_layers(doc)
            else:
                log(f"Moving to: {new_active.name()}")

        doc.setActiveNode(new_active)

        # Solo mode visibility
        background = self.get_background_layer(root_layers)
        for layer in root_layers:
            layer.setVisible(layer == new_active or layer == background)

        doc.refreshProjection()
        log(f"Active now: {new_active.name()}")


Krita.instance().addExtension(LayerSoloNav(Krita.instance()))
