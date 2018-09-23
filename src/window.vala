using FileUtil;

[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
class Window : Gtk.ApplicationWindow {
    [GtkChild]
    Gtk.Box filePaneContainer;

    IconManager iconManager = new IconManager ();

    public Window (Gtk.Application app) {
        Object (application: app);

        set_position (Gtk.WindowPosition.CENTER);
        set_default_size (700, 500);
        load_file_manager_icon ();

        key_press_event.connect (new_file_pane_handler);

        var filePane = new FilePane (iconManager, "/");
        filePaneContainer.add (filePane);
    }

    public bool new_file_pane_handler (Gdk.EventKey event) {
        var ctrlAndShift = Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK;
        if ( (event.state & ctrlAndShift) != ctrlAndShift ) {
            return false;
        }

        if ( event.keyval != Gdk.Key.N ) {
            return false;
        }

        var filePane = new FilePane (iconManager, "/");
        filePaneContainer.add (filePane);
        filePane.show ();

        return false;
    }

    private void load_file_manager_icon () {
        var appIcon = iconManager.get_application_icon ();
        if ( appIcon != null ) {
            icon = appIcon;
        }
    }

}
