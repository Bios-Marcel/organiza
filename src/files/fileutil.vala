using GLib.Math;

namespace FileUtil {

    /**
     * Converts a given file size into a simple, binary representation, that is
     * meant to be comprehensible to humans.
     */
    public string as_human_readable_binary(int64 file_size){
        const int64 unit = 1024;
        if (file_size < unit)
        {
            return file_size.to_string() + " B";
        }
        int64 exp = (int64) (Math.log(file_size) / Math.log(unit));
        string pre = "KMGTPE".get_char((long)exp-1).to_string() + "i";
        return format("%.1f %sB", file_size / pow(unit, exp), pre);
    }

    private string format(string some_string, ...){
        va_list va_list = va_list();
        return some_string.vprintf(va_list);
    }

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