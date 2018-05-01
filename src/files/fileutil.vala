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
	public int64 get_file_size (FileInfo fileInfo) {
	    if(fileInfo.get_file_type () == FileType.DIRECTORY) {
	        int64 size = 0;

	        //TODO Calculate size recursively

            return size;
 	    }
	    return fileInfo.get_size ();
	}
}