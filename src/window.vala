using FileUtil;

[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
public class Window : Gtk.ApplicationWindow {
    [GtkChild]
    Gtk.Paned rootLayout;

    [GtkChild]
    Gtk.Box filePaneContainer;

    Terminal terminal;

    [Signal (action = true)]
    public signal void focus_pane (int32 index);

    [Signal (action = true)]
    public signal void focus_terminal ();

    [Signal (action = true)]
    public signal void sync_wd ();

    IconManager iconManager = new IconManager ();

    static construct {
        set_css_name ("main-window");
    }

    public Window (Gtk.Application app) {
        Object (application: app);

        set_position (Gtk.WindowPosition.CENTER);
        set_default_size (700, 500);

        load_file_manager_icon ();
        focus_pane.connect ((index) => {
            Gtk.Widget widgetToFocus = get_file_pane (index);
            if ( widgetToFocus != null ) {
                widgetToFocus.grab_focus ();
            }
        });
        focus_terminal.connect (() => {
            terminal.grab_focus ();
        });

        load_css ("org/organiza/Organiza/key-bindings.css");
        key_press_event.connect (new_file_pane_handler);

        terminal = new Terminal (this);

        // TODO: Doesn't quite work yet.
        // sync_wd.connect (() => {
        // terminal.feed_child (@"cd $(get_dir_of_selected_file_pane())".to_utf8 ());
        // });

        rootLayout.add (terminal);

        var filePane = new FilePane (iconManager, "/");
        filePaneContainer.add (filePane);
    }

    private string ? get_dir_of_selected_file_pane () {
        Gtk.Widget pane = (filePaneContainer.get_focus_child () as FilePane);

        return (pane as FilePane).get_current_folder ();
    }

    private void load_css (string resource_path) {
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource (resource_path);
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    private Gtk.Widget ? get_file_pane (int32 index) {
        int32 currentIndex = 0;
        foreach ( Gtk.Widget element in filePaneContainer.get_children ()) {
            if ( currentIndex == index ) {
                return element;
            }

            currentIndex = currentIndex + 1;
        }

        return null;
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
