package gui

import (
	"github.com/gotk3/gotk3/gdk"
	"github.com/gotk3/gotk3/gtk"
)

var (
	cachedIcons     = make(map[string]*gdk.Pixbuf)
	placeholderIcon *gdk.Pixbuf
	folderIcon      *gdk.Pixbuf
)

//GetPixbuf loads and returns the file icon from the current icon theme.
//
//If the icon has not been loaded yet, it will be added to the cache. If it entered
//the cache once, it will only be loaded from the cache in the future.
func GetPixbuf( /* GLib FileInfo?*/ ) *gdk.Pixbuf {
	//TODO I first have to implement a way to retrieve Icons, as glib binding are incomplete.
	//For now, a placeholder will be used.

	if placeholderIcon == nil {
		placeholderIcon = loadPlaceholderIcon()
	}
	return placeholderIcon
}

//GetFolderIcon returns the icon themes icon for folders.
func GetFolderIcon() *gdk.Pixbuf {
	if folderIcon == nil {
		folderIcon = loadFolderIcon()
	}
	return folderIcon
}

func loadFolderIcon() *gdk.Pixbuf {
	iconTheme, iconThemeRetrievalError := gtk.IconThemeGetDefault()
	if iconThemeRetrievalError != nil {
		return nil
	}
	icon, iconLoadError := iconTheme.LoadIcon("folder", 24, 0)
	if iconLoadError != nil {
		return nil
	}

	return icon
}

func loadPlaceholderIcon() *gdk.Pixbuf {
	iconTheme, iconThemeRetrievalError := gtk.IconThemeGetDefault()
	if iconThemeRetrievalError != nil {
		return nil
	}
	icon, iconLoadError := iconTheme.LoadIcon("image-x-generic", 24, 0)
	if iconLoadError != nil {
		return nil
	}

	return icon
}

//GetApplicationIcon returns the applications main icon.
func GetApplicationIcon() *gdk.Pixbuf {
	iconTheme, iconThemeRetrievalError := gtk.IconThemeGetDefault()
	if iconThemeRetrievalError != nil {
		return nil
	}
	icon, iconLoadError := iconTheme.LoadIcon("system-file-manager", 48, 0)
	if iconLoadError != nil {
		return nil
	}

	return icon
}
