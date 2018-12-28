[GtkTemplate (ui = "/org/organiza/Organiza/window.ui")]
public class Window : Gtk.ApplicationWindow {
    [GtkChild]
    Gtk.Paned rootLayout;

    [GtkChild]
    FilePaneContainer filePaneContainer;

    [GtkChild]
    Gtk.Entry globalInputField;

    [GtkChild]
    Gtk.Label globalInputLabel;

    private inputAction ? currentInputAction;

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
        load_css ("org/organiza/Organiza/key-bindings.css");

        // Filepanes
        filePaneContainer.iconManager = iconManager;
        filePaneContainer.window = this;

        focus_pane.connect ((index) => {
            Gtk.Widget widgetToFocus = filePaneContainer.get_file_pane (index);
            if ( widgetToFocus != null ) {
                widgetToFocus.grab_focus ();
            }
        });

        filePaneContainer.new_file_pane ();
        filePaneContainer.get_file_pane (0).grab_focus ();

        // Global input field
        globalInputField.activate.connect (() => {
            if ( currentInputAction != null ) {

                currentInputAction (globalInputField.get_text ());
            }

            cancel_global_input_edit_handler ();
        });

        globalInputField.focus_out_event.connect ((event) => {
            cancel_global_input_edit_handler ();
            return false;
        });

        globalInputField.key_press_event.connect ((widget, event) => {
            if ( event.state == 0 && event.keyval == Gdk.Key.Escape ) {
                cancel_global_input_edit_handler ();
            }

            return false;
        });


        // Terminal
        terminal = new Terminal (this);

        focus_terminal.connect (() => {
            terminal.grab_focus ();
        });

        sync_wd.connect (() => {
            string ? command = "cd " + filePaneContainer.get_dir_of_selected_file_pane ();
            terminal.feed_child (command, command.length);
            terminal.grab_focus ();
        });

        rootLayout.add (terminal);
    }

    private void cancel_global_input_edit_handler () {
        globalInputLabel.set_text ("");
        globalInputField.set_text ("");
        globalInputField.set_sensitive (false);
        currentInputAction = null;
    }

    private void load_css (string resource_path) {
        var css_provider = new Gtk.CssProvider ();
        css_provider.load_from_resource (resource_path);
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    private void load_file_manager_icon () {
        var appIcon = iconManager.get_application_icon ();
        if ( appIcon != null ) {
            icon = appIcon;
        }
    }

    public delegate void inputAction (string inputString);

    public void run_input_action (string actionString, owned inputAction action) {
        globalInputLabel.set_text (actionString);
        currentInputAction = (owned) action;

        globalInputField.set_sensitive (true);
        globalInputField.grab_focus ();
    }

}
