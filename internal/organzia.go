package internal

import (
	"flag"

	"github.com/gotk3/gotk3/gdk"
	"github.com/gotk3/gotk3/glib"
	"github.com/gotk3/gotk3/gtk"

	"github.com/Bios-Marcel/Organiza/internal/gui"
)

//Start starts the application.
func Start() {
	flag.Parse()

	application, _ := gtk.ApplicationNew("me.bios-marcel.organiza", glib.APPLICATION_FLAGS_NONE)
	application.Connect("activate", func() {
		window, _ := gtk.ApplicationWindowNew(application)

		window.SetDefaultSize(700, 500)
		window.SetPosition(gtk.WIN_POS_CENTER)
		window.SetTitle("Organiza")

		path := flag.Arg(0)
		if len(path) == 0 {
			path = "/"
		}

		filePane := gui.CreateFilePane(&window.Window, path)

		layout, _ := gtk.BoxNew(gtk.ORIENTATION_HORIZONTAL, 10)
		layout.Add(filePane.GetRootWidget())

		window.Connect("key_release_event", func(window *gtk.ApplicationWindow, event *gdk.Event) {
			keyEvent := gdk.EventKeyNewFromEvent(event)
			keyEventState := keyEvent.State()

			if (keyEventState & (uint)(gdk.GDK_CONTROL_MASK|gdk.GDK_SHIFT_MASK)) == (uint)(gdk.GDK_CONTROL_MASK|gdk.GDK_SHIFT_MASK) {
				keyVal := keyEvent.KeyVal()

				if keyVal == gdk.KEY_N {
					filePaneNew := gui.CreateFilePane(&window.Window, "/")
					layout.Add(filePaneNew.GetRootWidget())
					filePaneNew.GetRootWidget().ShowAll()
				}
			}
		})

		window.Add(layout)
		window.SetIcon(gui.GetApplicationIcon())

		window.ShowAll()
	})

	application.Run(nil)
}
