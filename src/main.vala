
int main (string[] args) {
	var app = new Gtk.Application ("org.gnome.Organiza", ApplicationFlags.FLAGS_NONE);
	app.activate.connect (() => {
		var win = app.active_window;
		if (win == null) {
			win = new Organiza.Window (app);
		}
		win.present ();
	});

	return app.run (args);
}
