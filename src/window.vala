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

                    //TODO Currently the displayed item is just a forbidden sign; find a way to find the mime types icon.
                    currentFolderHierarchy.set (iter, 0, childFileInfo.get_symbolic_icon (), 1, childFileInfo.get_name (), 2, fileSize);
                }
                select_first ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
		}

        /**
         * Handles leftclicks in the fileView.
         */
        private void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            string name;

            treeview.get_selection().get_selected (out model, out iter);
            model.get (iter, 1, out name);

            var file = File.new_for_path (currentRootDirectory + "/" + name);
            if(FileUtil.is_directory (file)) {
                currentRootDirectory = currentRootDirectory + "/" + name;
                updateFileView();
            }
            stdout.printf("\t%s\n", currentRootDirectory);
        }
	}
}
