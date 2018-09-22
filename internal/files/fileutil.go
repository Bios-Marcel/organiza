package files

import (
	"fmt"

	"github.com/gotk3/gotk3/gtk"
	"github.com/skratchdot/open-golang/open"
)

const (
	kilo int64 = 1024
	mega int64 = 1048576
	giga int64 = 1073741824
	tera int64 = 1099511627776
	peta int64 = 1125899906842624
	exa  int64 = 1152921504606846976
)

func ToHumanReadableFileSize(fileSize int64) string {
	if fileSize < 0 {
		// what does a negative file size even mean?
		// obviously, FileInfo.get_size mentions none of it...
		return ""
	}

	normalizedSize := fileSize
	var suffix = "B"

	// in case of performance concerns, the order of these if-blocks
	// could be swapped. however, without benchmarks that would be pointless.
	// even with benchmarks, one has to consider typical file sizes (1KB - 1 GB
	// in 2018, would be my guess) as opposed to all possible file sizes.
	//
	// i have also experimented with fast bitwise integer operations.
	// however, that proved to be very imprecise for any number not cleanly
	// divisible by 2. i am sure, it would be possible enhance the accuracy
	// of integer divisions, but
	// a. the effort should only be undertaken in case of perf problems
	// b. surely, some lib out there has solved this already.

	if fileSize >= kilo {
		normalizedSize = normalizedSize / 1024
		suffix = "KB"
	}
	if fileSize >= mega {
		normalizedSize = normalizedSize / 1024
		suffix = "MB"
	}
	if fileSize >= giga {
		normalizedSize = normalizedSize / 1024
		suffix = "GB"
	}
	if fileSize >= tera {
		normalizedSize = normalizedSize / 1024
		suffix = "TB"
	}
	if fileSize >= peta {
		normalizedSize = normalizedSize / 1024
		suffix = "PB"
	}
	if fileSize >= exa {
		normalizedSize = normalizedSize / 1024
		suffix = "EB"
	}

	humanReadableString := fmt.Sprintf("%d %s", normalizedSize, suffix)
	return humanReadableString
}

func OpenFile(file string) {
	errorOpeningFile := open.Start(file)
	if errorOpeningFile != nil {
		displayCouldntOpenDialog(errorOpeningFile)
	}
}

func OpenFileWith(file string, with string) {
	errorOpeningFile := open.StartWith(file, with)
	if errorOpeningFile != nil {
		displayCouldntOpenDialog(errorOpeningFile)
	}
}

func displayCouldntOpenDialog(errorOpeningFile error) {
	//TODO Pass parent window
	message := fmt.Sprintf("Error opening file (%s)", errorOpeningFile.Error())
	openFileErrorDialog := gtk.MessageDialogNew(nil, gtk.DIALOG_DESTROY_WITH_PARENT, gtk.MESSAGE_ERROR, gtk.BUTTONS_OK, message)
	openFileErrorDialog.Run()
	openFileErrorDialog.Destroy()
}

func ChooseApplicationOpenFile(file string) {
	//
}
