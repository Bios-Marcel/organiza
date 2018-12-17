using FileUtil;

/*delegate void VoidFunc ();

   class VoidFuncData {
    public VoidFunc func;

    public VoidFuncData (owned VoidFunc func) {
        this.func = (owned) func;
    }

   }*/

[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
class Window : Gtk.ApplicationWindow {
    [GtkChild]
    Gtk.Paned rootLayout;

    [GtkChild]
    Gtk.Box filePaneContainer;

    Vte.Terminal terminal;

    IconManager iconManager = new IconManager ();

    public Window (Gtk.Application app) {
        Object (application: app);

        set_position (Gtk.WindowPosition.CENTER);
        set_default_size (700, 500);
        load_file_manager_icon ();

        key_press_event.connect (new_file_pane_handler);
        key_release_event.connect (focus_request_handler);

        terminal = new Vte.Terminal ();
        terminal.child_exited.connect ((t) => { Gtk.main_quit (); });
        Pid pid;

        // TODO Handle error and see how to replace call to spawn_sync
        terminal.spawn_sync (Vte.PtyFlags.DEFAULT,
                             null, /* working directory */
                             { "bash" },
                             null, /* environment */
                             GLib.SpawnFlags.SEARCH_PATH,
                             null, /* child setup */
                             out pid, /* child pid */
                             null /* cancellable */);
        rootLayout.add (terminal);

        var filePane = new FilePane (iconManager, "/");
        filePaneContainer.add (filePane);
    }

    public bool focus_request_handler (Gdk.EventKey event) {
        if ( event.state != 0 ) {
            return false;
        }

        if ( event.keyval == Gdk.Key.dead_circumflex ) {
            terminal.grab_focus ();
            return false;
        }

        int32 position = 0;
        foreach ( Gtk.Widget element in filePaneContainer.get_children ()) {
            if ( position == 0 && event.keyval == Gdk.Key.F1 ) {
                element.grab_focus ();
                break;
            } else if ( position == 1 && event.keyval == Gdk.Key.F2 ) {
                element.grab_focus ();
                break;
            } else if ( position == 2 && event.keyval == Gdk.Key.F3 ) {
                element.grab_focus ();
                break;
            } else if ( position == 3 && event.keyval == Gdk.Key.F4 ) {
                element.grab_focus ();
                break;
            } else if ( position == 4 && event.keyval == Gdk.Key.F5 ) {
                element.grab_focus ();
                break;
            } else if ( position == 5 && event.keyval == Gdk.Key.F6 ) {
                element.grab_focus ();
                break;
            } else if ( position == 6 && event.keyval == Gdk.Key.F7 ) {
                element.grab_focus ();
                break;
            } else if ( position == 7 && event.keyval == Gdk.Key.F8 ) {
                element.grab_focus ();
                break;
            } else if ( position == 8 && event.keyval == Gdk.Key.F9 ) {
                element.grab_focus ();
                break;
            } else if ( position == 9 && event.keyval == Gdk.Key.F10 ) {
                element.grab_focus ();
                break;
            } else if ( position == 10 && event.keyval == Gdk.Key.F11 ) {
                element.grab_focus ();
                break;
            } else if ( position == 11 && event.keyval == Gdk.Key.F12 ) {
                element.grab_focus ();
                break;
            } else {
                position = position + 1;
            }
        }

        return false;
    }

    public bool new_file_pane_handler (Gdk.EventKey event) {
        var ctrlAndShift = Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK;
        if ((event.state & ctrlAndShift) != ctrlAndShift ) {
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
