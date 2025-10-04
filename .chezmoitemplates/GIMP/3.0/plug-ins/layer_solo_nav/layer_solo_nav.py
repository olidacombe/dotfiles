#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import gi
import sys

gi.require_version("Gimp", "3.0")
from gi.repository import Gimp, GObject, GLib

my_name = "Oli Dacombe"
year = 2025


class LayerSoloNav(Gimp.PlugIn):
    def do_query_procedures(self):
        return ["python-fu-layer-down-solo", "python-fu-layer-up-solo"]

    def do_create_procedure(self, name):
        if name == "python-fu-layer-down-solo":
            proc = Gimp.ImageProcedure.new(
                self, name, Gimp.PDBProcType.PLUGIN, self.run_layer_down, None
            )
            proc.set_menu_label("Layer Down (Solo Prev)")
            proc.set_documentation(
                "Solo the next layer down and the background",
                "Solo the next lower layer.",
                name,
            )
            proc.set_attribution(my_name, my_name, f"{year}")
            proc.set_image_types("*")
            proc.add_menu_path("<Image>/Layer")
            return proc

        elif name == "python-fu-layer-up-solo":
            proc = Gimp.ImageProcedure.new(
                self, name, Gimp.PDBProcType.PLUGIN, self.run_layer_up, None
            )
            proc.set_menu_label("Layer Up (Solo Next or New)")
            proc.set_documentation(
                "Solo the next layer up (or create one) and the background",
                "Solo next higher layer.",
                name,
            )
            proc.set_attribution(my_name, my_name, f"{year}")
            proc.set_image_types("*")
            proc.add_menu_path("<Image>/Layer")
            return proc

        return None

    def run_layer_down(self, procedure, run_mode, image, drawables, return_vals, data):
        image.undo_group_start()

        layers = image.get_layers()
        selected_layers = image.get_selected_layers()
        active = selected_layers[0] if selected_layers else None

        if active and active in layers:
            active_index = layers.index(active)
        else:
            active_index = None

        background = layers[-1] if layers else None
        if background:
            background.set_visible(True)

        if active_index is not None and active_index + 1 < len(layers):
            new_active = layers[active_index + 1]
            image.set_selected_layers([new_active])

            for lyr in layers:
                if lyr is new_active or lyr is background and background is not None:
                    lyr.set_visible(True)
                else:
                    lyr.set_visible(False)

        image.undo_group_end()
        Gimp.displays_flush()
        return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())

    def run_layer_up(self, procedure, run_mode, image, drawables, return_vals, data):
        image.undo_group_start()

        layers = image.get_layers()
        selected_layers = image.get_selected_layers()
        active = selected_layers[0] if selected_layers else None

        background = layers[-1] if layers else None
        if background:
            background.set_visible(True)

        if active and active in layers:
            active_index = layers.index(active)
        else:
            active_index = None

        if active_index is not None and active_index > 0:
            new_active = layers[active_index - 1]
        else:
            new_active = Gimp.Layer.new(
                image,
                "New Layer",
                image.get_width(),
                image.get_height(),
                Gimp.ImageType.RGBA_IMAGE,
                100.0,
                Gimp.LayerMode.NORMAL,
            )
            image.insert_layer(new_active, None, 0)
        image.set_selected_layers([new_active])

        for lyr in layers:
            if lyr is new_active or lyr is background:
                lyr.set_visible(True)
            else:
                lyr.set_visible(False)

        image.undo_group_end()
        Gimp.displays_flush()
        return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())


Gimp.main(LayerSoloNav.__gtype__, sys.argv)
