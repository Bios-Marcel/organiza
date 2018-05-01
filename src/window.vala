using FileUtil;

namespace Organiza {
	[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		[GtkChild]
		Gtk.ListStore currentFolderHierarchy;

        [GtkChild]
        Gtk.TreeView fileView;

        string currentRootDirectory = "/";

		public Window (Gtk.Application app) {
			Object (application: app);
			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default ();
		    try {
			    icon = icon_theme.load_icon ("system-file-manager", 48, 0);
		    } catch (Error e) {
			    warning (e.message);
		    }

		    updateFileView ();
		    fileView.row_activated.connect (on_row_activated);
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
                var enumerator = directory.enumerate_children ("standard::*", 0);

                FileInfo fileInfo;
                while ((fileInfo = enumerator.next_file ()) != null) {
                    Gtk.TreeIter iter;
                    currentFolderHierarchy.append (out iter);
                    currentFolderHierarchy.set (iter, 0, fileInfo.get_name (), 1, FileUtil.get_file_size (fileInfo));
                }
                select_first ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
		}

		/* List item selection handler. */
        private void on_row_activated (Gtk.TreeView treeview , Gtk.TreePath path, Gtk.TreeViewColumn column) {            stdout.printf("\tSelection changed\n");
            Gtk.TreeModel model;
            Gtk.TreeIter iter;
            string name;

            treeview.get_selection().get_selected (out model, out iter);
            model.get (iter, 0, out name);

            var file = File.new_for_path (currentRootDirectory + "/" + name);
            if(FileUtil.is_directory (file)) {
                currentRootDirectory = currentRootDirectory + "/" + name;
                updateFileView();
            }
            stdout.printf("\t%s\n", currentRootDirectory);
        }
	}
}
