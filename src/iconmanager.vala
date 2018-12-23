class IconManager {
    // We needn't retrieve the theme over and over again.
    public Gtk.IconTheme iconTheme = Gtk.IconTheme.get_default ();

    // TODO Marcel: I'd prefer using Icon.hash () over Icon.to_string (); Find out how to use uint properly in HashTable
    // Used for caching icons in order to decrease loading time when switching folders
    HashTable<string, Gdk.Pixbuf> iconCache = new HashTable<string, Gdk.Pixbuf> (str_hash, str_equal);

    /**
     * Loads and returns the icon which the current icon theme uses for the given FileInfo.
     *
     * If the icon has already been loaded at some point we will retrieve it from our cache and return it.
     * In case the icon hasn't already been loaded, we will look it up, load it, add it to the cache and then return it.
     *
     * @param info the FileInfo to retrieve the icon for
     *
     * @return the retrieved icon or ``null``
     */
    public Gdk.Pixbuf ? get_pixbuf_icon (FileInfo info) {
        // TODO Consider not using a constant icon size.
        // TODO Implement a proper error-treatment.

        try {
            var icon = info.get_icon ();
            var iconAsString = icon.to_string ();
            var pixbuf = iconCache.get (iconAsString);
            if ( pixbuf == null ) {
                // If the icon isn't cached yet, we will look it up, add it to the cache and return it.
                pixbuf = iconTheme.lookup_by_gicon (icon, 24, Gtk.IconLookupFlags.USE_BUILTIN).load_icon ();
                iconCache.insert (iconAsString, pixbuf);
            }

            // by now pixbuf will be non-null and cached.
            return pixbuf;
        } catch ( Error error ) {
            critical ("Error retrieving icon for file: %s\n", info.get_name ());
            return null;
        }
    }

    /**
     * @return the file manager icon of the current icon theme
     */
    public Gdk.Pixbuf ? get_application_icon () {
        try {
            return iconTheme.load_icon ("system-file-manager", 48, 0);
        } catch ( Error e ) {
            warning (e.message);
            // In case we can't find an icon, we just won't return one.
            return null;
        }
    }
}
