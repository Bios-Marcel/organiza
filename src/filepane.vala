[GtkTemplate (ui = "/org/organiza/Organiza/filepane.ui")]
class FilePane : Gtk.ScrolledWindow {
    [GtkChild]
    private Gtk.TreeView fileView;
    [GtkChild]
    private Gtk.ListStore fileTree;

    [Signal (action = true)]
    public signal void navigate_down ();

    [Signal (action = true)]
    public signal void navigate_up ();

    [Signal (action = true)]
    public signal void new_file ();

    [Signal (action = true)]
    public signal void move_file ();

    [Signal (action = true)]
    public signal void delete_file ();

    [Signal (action = true)]
    public signal void trash_file ();

    private Window window;

    private string currentDirectory = "/";
    private FileMonitor ? currentDirectoryMonitor;

    private IconManager iconManager;

    static construct {
        set_css_name ("file-pane");
    }

    construct {
        navigate_down.connect_after (navigate_down_handler);
        navigate_up.connect (navigate_up_handler);
        fileView.key_press_event.connect (on_arrow_key_navigation);
        button_press_event.connect (button_press_handler);

        new_file.connect (new_file_handler);
        move_file.connect (move_file_handler);
        delete_file.connect (delete_file_handler);
        trash_file.connect (trash_file_handler);
    }

    public FilePane (Window window, IconManager iconManager, string directory) {
        this.window = window;
        this.iconManager = iconManager;
        this.currentDirectory = directory;

        fileTree.set_sort_column_id (1, Gtk.SortType.ASCENDING);
        fileTree.set_sort_func (1, (model, iterOne, iterTwo) => {
            GLib.Value nameOne;
            GLib.Value nameTwo;

            model.get_value (iterOne, 1, out nameOne);
            model.get_value (iterTwo, 1, out nameTwo);

            string nameOneString = (string) nameOne;
            string nameTwoString = (string) nameTwo;

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

    private bool button_press_handler (Gdk.EventButton event) {
        if ( event.state != 0 ) {
            return false;
        }

        // TODO: This is the back button on the mouse, is there some constant for this?
        if ( event.button == 8 ) {
            navigate_up_handler ();
            return true;
        }

        return false;
    }

    private bool on_arrow_key_navigation (Gtk.Widget widget, Gdk.EventKey event) {
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
        GLib.FileEnumerator enumerator = null;
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

            // FIXME The documentation suggests to use enumerate_children_async to not block the thread.
            enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NONE);

            Gtk.TreeIter iter;
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
        } finally {
            if ( enumerator != null ) {
                try {
                    enumerator.close ();
                } catch ( GLib.Error error ) {
                    critical ("Unable to close file enumerator: %s", error.message);
                }
            }
        }
        select_first ();
    }

    public void new_file_handler () {
        window.run_input_action ("Create new file at: " + currentDirectory, (inputString) => {
            string fileToCreate = currentDirectory + inputString;
            try {
                File file = File.new_for_path (fileToCreate);
                if ( inputString.has_suffix ("/")) {
                    file.make_directory_with_parents ();
                } else {
                    File parent = file.get_parent ();
                    if ( !parent.query_exists ()) {
                        parent.make_directory_with_parents ();
                    }
                    FileOutputStream stream = file.create (FileCreateFlags.PRIVATE);
                    stream.close ();
                }
            } catch ( GLib.Error error ) {
                critical ("Error creating file '%s': %s", fileToCreate, error.message);
            }

            grab_focus ();
        });
    }

    public void move_file_handler () {
        string filePath = currentDirectory + get_selected_file_name ();
        window.run_input_action ("Move file: " + filePath, (inputString) => {
            string oldFile = currentDirectory + get_selected_file_name ();
            string newFile = null;

            if ( inputString.has_prefix ("/")) {
                newFile = inputString;
            } else {
                newFile = currentDirectory + inputString;
            }

            File file = File.new_for_path (newFile);
            File parent = file.get_parent ();

            try {
                if ( !parent.query_exists ()) {
                    parent.make_directory_with_parents ();
                }

                GLib.FileUtils.rename (oldFile, newFile);
            } catch ( GLib.Error error ) {
                critical ("Error moving file '%s' to'%s': %s", oldFile, newFile, error.message);
            } finally {
                grab_focus ();
            }
        });
    }

    public void delete_file_handler () {
        string filePath = currentDirectory + get_selected_file_name ();
        try {
            Process.spawn_async ("/",
                                 { "rm", "--recursive", "--force", filePath },
                                 null,
                                 SpawnFlags.SEARCH_PATH,
                                 null,
                                 null);
        } catch ( GLib.SpawnError error ) {
            critical ("Error deleting file '%s'; %s", filePath, error.message);
        }
    }

    public void trash_file_handler () {
        string filePath = currentDirectory + get_selected_file_name ();
        try {
            Process.spawn_async ("/",
                                 { "gio", "trash", "--force", filePath },
                                 null,
                                 SpawnFlags.SEARCH_PATH,
                                 null,
                                 null);
        } catch ( GLib.SpawnError error ) {
            critical ("Error trashing file '%s'; %s", filePath, error.message);
        }
    }

    private void on_row_activated (Gtk.TreeView treeview, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        var selectedFile = get_selected_file ();
        if ( selectedFile.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY ) {
            navigate_down_handler_unsafe ();
        } else {
            FileUtil.open_file (selectedFile);
        }
    }

    public string get_current_folder () {
        return currentDirectory;
    }

    public void navigate_up_handler () {
        var parentFolder = File.new_for_path (currentDirectory).get_parent ();
        if ( parentFolder != null ) {
            currentDirectory = parentFolder.get_path ();
            fix_current_dir_path_if_necessary ();
            update_file_view ();
        }
    }

    public void navigate_down_handler () {
        var selectedFile = get_selected_file ();
        if ( selectedFile.query_file_type (FileQueryInfoFlags.NONE) == FileType.DIRECTORY ) {
            navigate_down_handler_unsafe ();
        }
    }

    private void fix_current_dir_path_if_necessary () {
        if ( !currentDirectory.has_suffix (Path.DIR_SEPARATOR_S)) {
            currentDirectory = currentDirectory + Path.DIR_SEPARATOR_S;
        }
    }

    private void navigate_down_handler_unsafe () {
        var file = get_selected_file ();
        fix_current_dir_path_if_necessary ();

        currentDirectory = currentDirectory + file.get_basename () + Path.DIR_SEPARATOR_S;
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
