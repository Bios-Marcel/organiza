using FileUtil;

[GtkTemplate (ui = "/org/organiza/Organiza/filepane.ui")]
class FilePane : Gtk.ScrolledWindow {
    [GtkChild]
    Gtk.TreeView fileView;
    [GtkChild]
    Gtk.ListStore fileTree;

    string currentDirectory = "/";
    FileMonitor ? currentDirectoryMonitor;

    IconManager iconManager;

    public FilePane (IconManager iconManager, string directory) {
        this.iconManager = iconManager;

        fileView.popup_menu.connect (() => {
            // TODO Is necessary for shift + f10 and the "context menu"-key to work
            return false;
        });

        key_press_event.connect (delete_file_pane_handler);

        fileTree.set_sort_column_id (1, Gtk.SortType.ASCENDING);
        fileTree.set_sort_func (1, (model, iterOne, iterTwo) => {
            GLib.Value nameOne;
            GLib.Value nameTwo;

            model.get_value (iterOne, 1, out nameOne);
            model.get_value (iterTwo, 1, out nameTwo);

            string nameOneString = (string) nameOne;
            string nameTwoString = (string) nameTwo;

            // TODO Find out if this might this be a huge performance impact? Instead keep file-informations about entries and use those?
            File fileOne = File.new_for_path (currentDirectory + Path.DIR_SEPARATOR_S + nameOneString);
            File fileTwo = File.new_for_path (currentDirectory + Path.DIR_SEPARATOR_S + nameTwoString);
            FileType fileTypeOne = fileOne.query_file_type (FileQueryInfoFlags.NONE);
            FileType fileTypeTwo = fileTwo.query_file_type (FileQueryInfoFlags.NONE);

            if ( fileTypeOne == FileType.DIRECTORY && fileTypeTwo != FileType.DIRECTORY ) {
                return -1;
            }
            if ( fileTypeTwo == FileType.DIRECTORY && fileTypeOne != FileType.DIRECTORY ) {
                return 1;
            }

            if ( nameOneString >= nameTwoString ) {
                return 1;
            }
            if ( nameOneString == nameTwoString ) {
                return 0;
            }
            return -1;
        });

        update_file_view ();
        fileView.row_activated.connect (on_row_activated);
        fileView.key_press_event.connect (on_key_pressed);
    }

    public override void grab_focus () {
        fileView.grab_focus ();
    }

    private bool delete_file_pane_handler (Gdk.EventKey event) {
        var ctrlAndShift = Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK;
        if ((event.state & ctrlAndShift) != ctrlAndShift ) {
            return false;
        }

        if ( event.keyval != Gdk.Key.D ) {
            return false;
        }

        destroy ();

        return false;
    }

    private void select_first () {
        Gtk.TreeIter iter;
        if ( fileTree.get_iter_first (out iter)) {
            fileView.get_selection ().select_iter (iter);
            fileView.grab_focus ();
        }
    }

    private void update_file_view () {
        try {
            fileTree.clear ();

            var directory = File.new_for_path (currentDirectory);
            if ( currentDirectoryMonitor != null ) {
                currentDirectoryMonitor.cancel ();
            }

            currentDirectoryMonitor = directory.monitor (FileMonitorFlags.NONE, null);
            currentDirectoryMonitor.changed.connect ((src, dest, event) => {
                // TODO Marcel: Might it be better if i only update the entry containg the file?
                update_file_view ();
            });
            Gtk.TreeIter iter;

            // If there is a parent-folder, we wan't to give the user the opportunity to navigate there per mouse, therefore we add an `..` item.
            var parentFolder = directory.get_parent ();
            if ( parentFolder != null ) {
                fileTree.append (out iter);
                var folderIcon = iconManager.iconTheme.lookup_icon ("folder", 24, Gtk.IconLookupFlags.USE_BUILTIN).load_icon ();
                fileTree.set (iter, 0, folderIcon, 1, "..", 2, "");
            }

            // FIXME The documentation suggests to use enumerate_children_async to not block the thread.
            var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NONE);

            FileInfo childFileInfo;
            while ((childFileInfo = enumerator.next_file ()) != null ) {
                fileTree.append (out iter);

                string fileSize;
                if ( childFileInfo.get_file_type () == FileType.DIRECTORY ) {
                    // Calculating a directories recursively takes too long, therefore we won't display such info.
                    fileSize = "";
                } else {
                    fileSize = FileUtil.as_nerd_readable_file_size (childFileInfo.get_size ());
                }

                fileTree.set (iter, 0, iconManager.get_pixbuf_icon (childFileInfo), 1, childFileInfo.get_name (), 2, fileSize);
            }
        } catch ( Error error ) {
            critical ("Error updating fileview; Errormessage: %s\n", error.message);
        }

        select_first ();
    }

    /**
     * Handles leftclicks in the fileView.
     */
    private void on_row_activated (Gtk.TreeView treeview, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        if ( get_selected_file_name () == ".." ) {
            navigate_up ();
        } else {
            var selectedFile = get_selected_file ();
            if ( selectedFile.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY ) {
                navigate_down ();
            } else {
                FileUtil.open_file (selectedFile);
            }
        }
    }

    private bool on_key_pressed (Gtk.Widget widget, Gdk.EventKey event) {
        switch ( event.keyval ) {
            case Gdk.Key.Left: {
                navigate_up ();
                return true;
            }
            case Gdk.Key.Right: {
                var selectedFile = get_selected_file ();
                if ( get_selected_file_name () != ".."
                     && selectedFile.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY ) {
                    navigate_down ();
                    return true;
                }
                return false;
            }
        }

        return false;
    }

    private void navigate_up () {
        var parentFolder = File.new_for_path (currentDirectory).get_parent ();
        if ( parentFolder != null ) {
            currentDirectory = parentFolder.get_path ();
            update_file_view ();
        }
    }

    private void navigate_down () {
        var file = get_selected_file ();
        currentDirectory = currentDirectory + "/" + file.get_basename ();
        update_file_view ();
    }

    private string ? get_selected_file_name () {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        string name;

        fileView.get_selection ().get_selected (out model, out iter);
        model.get (iter, 1, out name);
        return name;
    }

    public File ? get_selected_file () {
        return File.new_for_path (currentDirectory + Path.DIR_SEPARATOR_S + get_selected_file_name ());
    }
}
