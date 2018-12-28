
public class Terminal : Vte.Terminal {

    static construct {
        set_css_name ("main-window-terminal");
    }

    [Signal (action = true)]
    public signal void focus_pane (int32 index);

    [Signal (action = true)]
    public signal void copy ();

    [Signal (action = true)]
    public signal void paste ();

    public Terminal (Window window) {
        focus_pane.connect ((index) => {
            window.focus_pane (index);
        });

        copy.connect (() => {
            copy_primary ();
        });

        paste.connect (() => {
            paste_primary ();
        });

        // TODO Handle error properly and see how to replace call to spawn_sync
        try {
            spawn_sync (Vte.PtyFlags.DEFAULT,
                        null, /* working directory */
                        { "bash" },
                        null, /* environment */
                        GLib.SpawnFlags.SEARCH_PATH,
                        null, /* child setup */
                        null, /* child pid */
                        null /* cancellable */);
        } catch ( GLib.Error error ) {
            critical ("An error occured while trying to build up the terminal: %s", error.message);
        }
    }

}