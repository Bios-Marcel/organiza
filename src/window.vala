using FileUtil;

namespace Organiza {
	[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
	public class Window : Gtk.ApplicationWindow {
        [GtkChild]
        Gtk.TreeView fileView;
		[GtkChild]
		Gtk.ListStore currentFolderHierarchy;

        string currentRootDirectory = "/";

		public Window (Gtk.Application app) {
			Object (application: app);

            loadFileManagerIcon();
            updateFileView ();
		    fileView.row_activated.connect (on_row_activated);
		    fileView.key_press_event.connect (on_key_pressed);
    	}

    	private void loadFileManagerIcon() {
    	    Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
		    try {
			    icon = icon_theme.load_icon ("system-file-manager", 48, 0);
		    } catch (Error e) {
			    warning (e.message);
			    //In case we can't find an icon, we just won't set one.
		    }

    	}

    	private void select_first() {
    	    Gtk.TreeIter iter;
            if (currentFolderHierarchy.get_iter_first(out iter)) {
                fileView.get_selection ().select_iter(iter);
            }
    	}

		private void updateFileView() {
            try {
                currentFolderHierarchy.clear ();
                var directory = File.new_for_path (currentRootDirectory);
                var enumerator = directory.enumerate_children ("standard::*", FileQueryInfoFlags.NONE);

                FileInfo childFileInfo;
                while ((childFileInfo = enumerator.next_file ()) != null) {
                    Gtk.TreeIter iter;
                    currentFolderHierarchy.append (out iter);

                    string fileSize;
                    if(childFileInfo.get_file_type () == FileType.DIRECTORY) {
                        //Calculating a directories recursively takes too long, therefore we won't display such info.
                        fileSize = "";
                    } else {
                        fileSize = FileUtil.as_human_readable_binary(childFileInfo.get_size ());
                    }

                    currentFolderHierarchy.set (iter, 0, get_pixbuf_icon(childFileInfo), 1, childFileInfo.get_name (), 2, fileSize);
                }
                select_first ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
		}

        private Gdk.Pixbuf get_pixbuf_icon(FileInfo info) {
            //FIXME Currently only folder icons are displayed; Do i have to use something that is not the default theme?
            //TODO Consider not using a constant icon size
            //TODO Error treatment and performance optimization through caching.
            Gtk.IconTheme iconTheme = Gtk.IconTheme.get_default();
            Icon icon = info.get_icon();
            return iconTheme.load_icon(icon.to_string(), 24, Gtk.IconLookupFlags.USE_BUILTIN);
        }

        /**
         * Handles leftclicks in the fileView.
         */
        private void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
            navigate_down ();
        }

        private bool on_key_pressed(Gtk.Widget widget, Gdk.EventKey event) {
            if (event.keyval == Gdk.Key.Left) {
                navigate_up ();
                return true;
            } else if (event.keyval == Gdk.Key.Right) {
                navigate_down ();
                return true;
            }

            return false;
    	}

    	private void navigate_up() {
            var parentFolder = File.new_for_path (currentRootDirectory).get_parent ();
    	    if(parentFolder != null) {
    	        currentRootDirectory = parentFolder.get_path ();
    	        updateFileView();
    	    }
    	}

    	private void navigate_down () {
            var file = get_selected_file ();
            if(FileUtil.is_directory (file)) {
                currentRootDirectory = currentRootDirectory + "/" + file.get_basename ();
                updateFileView();
            }
    	}

    	private File get_selected_file() {
    	    Gtk.TreeModel model;
            Gtk.TreeIter iter;
            string name;

            fileView.get_selection().get_selected (out model, out iter);
            model.get (iter, 1, out name);

            return File.new_for_path (currentRootDirectory + "/" + name);
    	}
	}
}
