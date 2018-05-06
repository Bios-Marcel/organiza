namespace Tests {
    using Test;
    using FileUtil;

    void add_fileutil_tests () {
        Test.add_func ("/files/fileutil/as_nerd_readable_file_size", () => {

        assert_equals (as_nerd_readable_file_size(-1), "");
        assert_equals (as_nerd_readable_file_size(-100), "");

        assert_equals (as_nerd_readable_file_size(0), "0 B");
        assert_equals (as_nerd_readable_file_size(1), "1 B");
        assert_equals (as_nerd_readable_file_size(2), "2 B");
        assert_equals (as_nerd_readable_file_size(55), "55 B");
        assert_equals (as_nerd_readable_file_size(99), "99 B");
        assert_equals (as_nerd_readable_file_size(999), "999 B");
        assert_equals (as_nerd_readable_file_size(1023), "1023 B");

        // 1024^1 1024 B == 1 KB
        assert_equals (as_nerd_readable_file_size(1000), "1000 B");
        assert_equals (as_nerd_readable_file_size(1024), "1 KB");
        assert_equals (as_nerd_readable_file_size(34647), "34 KB");
        assert_equals (as_nerd_readable_file_size(654323), "639 KB");

        // 1024^2 == 1048576 B == 1 MB
        assert_equals (as_nerd_readable_file_size(1048570), "1024 KB");
        assert_equals (as_nerd_readable_file_size(1048576), "1 MB");
        assert_equals (as_nerd_readable_file_size(6564567), "6 MB");
        assert_equals (as_nerd_readable_file_size(13265667), "13 MB");

        // 1024^3 == 1073741824 == 1 GB
        assert_equals (as_nerd_readable_file_size(1073741820), "1024 MB");
        assert_equals (as_nerd_readable_file_size(1073741824), "1 GB");
        assert_equals (as_nerd_readable_file_size(45179874321), "42 GB");
        assert_equals (as_nerd_readable_file_size(886879874321), "826 GB");

        // 1024^4 == 1099511627776 == 1 TB
        assert_equals (as_nerd_readable_file_size(1099511627770), "1024 GB");
        assert_equals (as_nerd_readable_file_size(1099511627776), "1 TB");
        assert_equals (as_nerd_readable_file_size(86745676536574), "79 TB");
        assert_equals (as_nerd_readable_file_size(134165765398211), "122 TB");

        // 1024^5 == 1125899906842624 == 1 PB
        assert_equals (as_nerd_readable_file_size(1125899906842620), "1024 TB");
        assert_equals (as_nerd_readable_file_size(1125899906842624), "1 PB");
        assert_equals (as_nerd_readable_file_size(71176567887330129), "63 PB");
        assert_equals (as_nerd_readable_file_size(790963723023183838), "703 PB");

        // 1024^6 == 1152921504606846976 == 1 EB
        assert_equals (as_nerd_readable_file_size(1152921504606846970), "1024 PB");
        assert_equals (as_nerd_readable_file_size(1152921504606846976), "1 EB");
        assert_equals (as_nerd_readable_file_size(7154921204676846234), "6 EB");

        //int64.MAX
        assert_equals (as_nerd_readable_file_size(9223372036854775807), "8 EB");
        });
    }

    inline void assert_equals(string actual, string expected){
        if(expected == actual){
            //in case of vala black magic, pass check expression again:
            assert (expected == actual);
        }
        else
        {
            GLib.message(@"Expected value '$expected', but got '$actual' instead.");
            Test.fail();
        }
    }

    void main (string[] args) {
        Test.init (ref args);
        add_fileutil_tests ();
        Test.run ();
    }
}
