namespace FileUtil {

    /**
     * Queries a file to check if it is a directory.
     */
    public bool is_directory (File file) {
        return file.query_file_type(FileQueryInfoFlags.NONE) == FileType.DIRECTORY;
    }

    /**
     * Returns the size of a given file or `0` if given file is a folder.
     */
	public int64 get_file_size (File file) {
	    try {
            FileInfo fileInfo = file.query_info("standard::*", FileQueryInfoFlags.NONE);
	        if(fileInfo.get_file_type () == FileType.DIRECTORY) {
	            int64 size = 0;

                var enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

                FileInfo childFileInfo;
                while ((childFileInfo = enumerator.next_file ()) != null) {
                    size += get_file_size(file.resolve_relative_path(childFileInfo.get_name ()));
                }

                return size;
     	    } else {
        	    return fileInfo.get_size ();
     	    }
	    } catch (Error error) {
            warning(error.message);
	        return 0;
	    }
	}
}