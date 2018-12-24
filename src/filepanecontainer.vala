[GtkTemplate (ui = "/org/organiza/Organiza/filepanecontainer.ui")]
class FilePaneContainer : Gtk.Box {
    public IconManager iconManager;

    public Window window;

    [Signal (action = true)]
    public signal void new_file_pane ();

    [Signal (action = true)]
    public signal void delete_file_pane ();

    static construct {
        set_css_name ("file-pane-container");
    }

    construct {
        new_file_pane.connect (new_file_pane_handler);
        delete_file_pane.connect (delete_file_pane_handler);
    }

    public string ? get_dir_of_selected_file_pane () {
        Gtk.Widget pane = (get_focus_child () as FilePane);

        // Possible nullpointer?
        return (pane as FilePane).get_current_folder ();
    }

    public Gtk.Widget ? get_file_pane (int32 index) {
        int32 currentIndex = 0;
        foreach ( Gtk.Widget element in get_children ()) {
            if ( currentIndex == index ) {
                return element;
            }

            currentIndex = currentIndex + 1;
        }

        return null;
    }

    public void new_file_pane_handler () {
        var filePane = new FilePane (window, iconManager, "/");
        add (filePane);
        filePane.show_all ();
    }

    public void delete_file_pane_handler () {
        Gtk.Widget focusedChild = get_focus_child ();
        if ( focusedChild == null ) {
            return;
        }

        uint childrenAmount = get_children ().length ();
        // The last pane should stay, as the filemanager is useless otherwise.
        if ( childrenAmount < 2 ) {
            return;
        }

        // Since the currently focused pane gets deleted, we need to determine
        // a new focus target.
        uint indexOfFocusedChild = get_children ().index (focusedChild);
        if ( indexOfFocusedChild == (childrenAmount - 1)) {
            get_children ().nth_data (0).grab_focus ();
        } else {
            get_children ().nth_data (indexOfFocusedChild + 1).grab_focus ();
        }

        focusedChild.destroy ();
    }

}