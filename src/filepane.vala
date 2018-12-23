using FileUtil;

[GtkTemplate (ui = "/org/organiza/Organiza/filepane.ui")]
class FilePane : Gtk.ScrolledWindow {
    [GtkChild]
    private Gtk.TreeView fileView;
    [GtkChild]
    private Gtk.ListStore fileTree;

    /*[Signal (action = true)]
       public signal bool navigate_down ();

       [Signal (action = true)]
       public signal bool navigate_up ();*/

    private string currentDirectory = "/";
    private FileMonitor ? currentDirectoryMonitor;

    private IconManager iconManager;

    static construct {
        set_css_name ("file-pane");
    }

    construct {
        /*navigate_down.connect_after (navigate_down_handler);
           navigate_up.connect (navigate_up_handler);*/
        fileView.key_press_event.connect (on_key_pressed);
    }

    public FilePane (IconManager iconManager, string directory) {
        this.iconManager = iconManager;

        fileView.popup_menu.connect (() => {
            // TODO Is necessary for shift + f10 and the "context menu"-key to work
            return false;
        });

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
    }

    private bool on_key_pressed (Gtk.Widget widget, Gdk.EventKey event) {
        if ( event.state != 0 ) {
            return false;
        }

        switch ( event.keyval ) {
            case Gdk.Key.Left: {
                navigate_up_handler ();
                return true;
            }
            case Gdk.Key.Right: {
                navigate_down_handler ();
                return true;
            }
        }

        return false;
    }

    public override void grab_focus () {
        fileView.grab_focus ();
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
        var selectedFile = get_selected_file ();
        if ( !navigate_down_handler ()) {
            FileUtil.open_file (selectedFile);
        }
    }

    public string get_current_folder () {
        return currentDirectory;
    }

    public bool navigate_up_handler () {
        var parentFolder = File.new_for_path (currentDirectory).get_parent ();
        if ( parentFolder != null ) {
            currentDirectory = parentFolder.get_path ();
            update_file_view ();
            return true;
        }

        return false;
    }

    public bool navigate_down_handler () {
        var selectedFile = get_selected_file ();
        if ( selectedFile.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY ) {
            navigate_down_handler_unsafe ();
            return true;
        }

        return false;
    }

    private void navigate_down_handler_unsafe () {
        var file = get_selected_file ();
        currentDirectory = currentDirectory + file.get_basename () + "/";
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
