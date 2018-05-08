using FileUtil;

namespace Organiza {
	[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
	public class Window : Gtk.ApplicationWindow {
        [GtkChild]
        Gtk.TreeView fileView;
		[GtkChild]
		Gtk.ListStore currentFolderHierarchy;

        string currentRootDirectory = "/";

        //We needn't retrieve the theme over and over again.
        Gtk.IconTheme iconTheme = Gtk.IconTheme.get_default();

        //TODO Marcel: I'd prefer using Icon.hash () over Icon.to_string (); Find out how to use uint properly in HashTable
        //Used for caching icons in order to decrease loading time when switching folders
        HashTable<string, Gdk.Pixbuf> iconCache = new HashTable<string, Gdk.Pixbuf> (str_hash, str_equal);


		public Window (Gtk.Application app) {
			Object (application: app);

            set_position (Gtk.WindowPosition.CENTER);
            set_default_size (700, 500);
            loadFileManagerIcon ();
            updateFileView ();
		    fileView.row_activated.connect (on_row_activated);
		    fileView.key_press_event.connect (on_key_pressed);
    	}

    	private void loadFileManagerIcon() {
		    try {
			    icon = iconTheme.load_icon ("system-file-manager", 48, 0);
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
                //FIXME The documentation suggests to use enumerate_children_async to not block the thread.
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
                        fileSize = FileUtil.as_nerd_readable_file_size(childFileInfo.get_size ());
                    }

                    currentFolderHierarchy.set (iter, 0, get_pixbuf_icon(childFileInfo), 1, childFileInfo.get_name (), 2, fileSize);
                }
                select_first ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
		}

        private Gdk.Pixbuf? get_pixbuf_icon(FileInfo info) {
            //TODO Consider not using a constant icon size
            //TODO Error treatment and performance optimization through caching.

            try {
                var icon = info.get_icon ();
                var iconHash =  icon.to_string ();
                var pixbuf = iconCache.get (iconHash);
                if(pixbuf == null) {
                    //If the icon isn't cached yet, we will look it up, add it to the cache and return it.
                    pixbuf = iconTheme.lookup_by_gicon(icon, 24, Gtk.IconLookupFlags.USE_BUILTIN).load_icon ();
                    iconCache.insert (iconHash, pixbuf);
                    return pixbuf;
                }

                //icon is cached already, therefore we return it.
                return pixbuf;

            } catch (Error error) {
                stderr.printf("Error retrieving icon for file: %s\n", info.get_name ());
                return null;
            }
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
