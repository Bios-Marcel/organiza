int main(string[] args) {

    Intl.setlocale(LocaleCategory.ALL, "");


    print(_("Does it work"));

    var app = new Gtk.Application ("org.organiza.Organiza", ApplicationFlags.FLAGS_NONE);
    app.activate.connect (() => {
        var win = app.active_window;
        if ( win == null ) {
            win = new Organiza.Window (app);
        }
        win.present ();
    });

    return app.run (args);
}
