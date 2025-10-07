#!/usr/bin/env python3

import gi
import os
import sys

gi.require_version("Gimp", "3.0")
from gi.repository import Gimp, GObject, GLib

gi.require_version("Gtk", "4.0")
from gi.repository.Gtk import FileChooserDialog, FileChooserAction, ResponseType

my_name = "Oli Dacombe"
year = 2025


class ExportLayersAsImagesPlugin(Gimp.PlugIn):
    def do_create_procedure(self, name):
        # Create a procedure for the plugin
        proc = Gimp.ImageProcedure.new(
            self, name, Gimp.PDBProcType.PLUGIN, self.export_layers, None
        )
        proc.set_menu_label("Export Layers")
        proc.set_documentation(
            "Export layers as separate images",
            "Export layers as separate images",
            name,
        )
        proc.set_attribution(my_name, my_name, f"{year}")
        proc.set_image_types("*")
        proc.add_menu_path("<Image>/File")
        return proc

    def do_query_procedures(self):
        # Return a list of procedures this plugin provides
        return ["python-fu-export-layers-as-images"]

    def export_layers(self, procedure, run_mode, image, drawables, return_vals, data):
        """Export each layer (except the bottom one) as a separate PNG image."""

        # Pass None as the parent for the file chooser dialog (no active window)
        dialog = FileChooserDialog(
            title="Select Destination Directory",
            parent=None,  # No parent window
            action=FileChooserAction.SELECT_FOLDER,
        )

        # Set up the dialog's action area for buttons
        dialog.set_modal(True)

        # Add Cancel and OK buttons using the new GTK 4 methods
        dialog.add_button("Cancel", ResponseType.CANCEL)
        dialog.add_button("OK", ResponseType.OK)

        # Connect the response signal to handle the dialog response
        dialog.connect("response", self.on_dialog_response, dialog, procedure, image)

        # Show the dialog
        dialog.show()

        # Ensure that GTK's main loop runs while waiting for the dialog interaction
        # This blocks the code until the dialog is closed, allowing user interaction.
        GLib.MainLoop().run()

        # Return SUCCESS after the user interacts with the dialog
        return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())

    def on_dialog_response(self, dialog, response, dialog_ref, procedure, image):
        """Handle the response from the file chooser dialog."""
        # If the response was OK (the user selected a directory)
        if response == ResponseType.OK:
            directory = dialog_ref.get_filename()

            if not directory:
                Gimp.message("No directory selected. Exiting.")
                dialog_ref.destroy()
                GLib.MainLoop().quit()  # Stop the main loop
                return procedure.new_return_values(
                    Gimp.PDBStatusType.FAIL, GLib.Error("No directory selected.")
                )

            # Make sure the directory exists, create it if it doesn't
            if not os.path.exists(directory):
                os.makedirs(directory)

            # Get the layers of the image
            layers = image.layers

            # Iterate through each layer, excluding the bottom layer
            for layer in layers[:-1]:  # Skip the last (bottom) layer
                layer_name = layer.name

                # Define the file path for exporting
                file_path = os.path.join(directory, f"{layer_name}.png")

                # Create a new image with only the current layer visible
                new_image = Gimp.Image(image.width, image.height, image.base_type)
                new_layer = layer.copy()
                new_image.add_layer(new_layer, 0)

                # Hide all layers except the current layer
                for other_layer in new_image.layers:
                    if other_layer != new_layer:
                        other_layer.hide()

                # Export the current layer as a PNG
                Gimp.file_png_save(new_image, new_layer, file_path, file_path, 0, 9)

                # Clean up the duplicated image to avoid memory issues
                Gimp.Image.delete(new_image)

            # Return SUCCESS once the task is completed
            dialog_ref.destroy()
            GLib.MainLoop().quit()  # Stop the main loop
            return procedure.new_return_values(Gimp.PDBStatusType.SUCCESS, GLib.Error())

        # If the response was CANCEL (the user canceled the dialog)
        dialog_ref.destroy()
        GLib.MainLoop().quit()  # Stop the main loop
        return procedure.new_return_values(
            Gimp.PDBStatusType.FAIL, GLib.Error("Operation canceled by user.")
        )


# Register and run the plugin
Gimp.main(ExportLayersAsImagesPlugin.__gtype__, sys.argv)
