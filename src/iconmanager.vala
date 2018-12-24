class IconManager {
    // We needn't retrieve the theme over and over again.
    public Gtk.IconTheme iconTheme = Gtk.IconTheme.get_default ();

    HashTable<uint, Gdk.Pixbuf> iconCache = new HashTable<uint, Gdk.Pixbuf> (direct_hash, direct_equal);

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
            var iconHash = icon.hash ();
            var pixbuf = iconCache.get (iconHash);
            if ( pixbuf == null ) {
                // If the icon isn't cached yet, we will look it up, add it to the cache and return it.
                pixbuf = iconTheme.lookup_by_gicon (icon, 24, Gtk.IconLookupFlags.USE_BUILTIN).load_icon ();
                iconCache.insert (iconHash, pixbuf);
            }

            // by now the pixbuf should be non-null and cached.
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
