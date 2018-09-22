package gui

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/Bios-Marcel/Organiza/internal/files"
	"github.com/Bios-Marcel/wastebasket"
	"github.com/gotk3/gotk3/gdk"
	"github.com/gotk3/gotk3/glib"
	"github.com/gotk3/gotk3/gtk"
)

//FilePane is the representation of the TreeView that represents the folder hierarchy.
type FilePane struct {
	parentWindow *gtk.Window

	rootWidget *gtk.Widget

	currentDirectory string
	treeModel        *gtk.ListStore
	fileTree         *gtk.TreeView
}

const (
	columnIcon = iota
	columnName
	columnSize
	columnIsDir
)

//CreateFilePane creates a FilePane with the given path as its default path.
func CreateFilePane(parentWindow *gtk.Window, path string) *FilePane {
	var hAdjustment, vAdjustment *gtk.Adjustment
	scrollPane, _ := gtk.ScrolledWindowNew(hAdjustment, vAdjustment)

	fileTree, _ := gtk.TreeViewNew()
	fileTree.SetVExpand(true)
	fileTree.SetHExpand(true)
	fileTree.AppendColumn(createNameColumn())
	fileTree.AppendColumn(createSizeColumn())

	treeModel, _ := gtk.ListStoreNew(glib.TYPE_OBJECT, glib.TYPE_STRING, glib.TYPE_STRING, glib.TYPE_BOOLEAN)
	treeModel.SetSortColumnId(columnName, gtk.SORT_ASCENDING)
	fileTree.SetModel(treeModel)

	scrollPane.Add(fileTree)
	scrollPane.SetVExpand(true)
	scrollPane.SetHExpand(true)

	filePane := FilePane{
		parentWindow: parentWindow,

		rootWidget: &scrollPane.Widget,

		treeModel: treeModel,
		fileTree:  fileTree,
	}
	filePane.SetPath(path)

	//HACK Not cool, as I can't ask the selection instantly
	fileTree.Connect("button-press-event", func(treeView *gtk.TreeView, event *gdk.Event) {
		buttonEvent := gdk.EventButtonNewFromEvent(event)

		//Only rightclick; There seems to be no constant...
		if buttonEvent.ButtonVal() != 3 {
			return
		}

		//TODO Currently doesn't work, as this is merely a hack anyway.
		//Only if there is any selection
		/*selection, _ := filePane.fileTree.GetSelection()
		if selection.CountSelectedRows() <= 0 {
			return
		}*/

		menu := createFileContextMenu(&filePane)
		menu.ShowAll()
		menu.PopupAtPointer(event)
	})
	fileTree.Connect("row-activated", func() {
		filePane.handleRowActivation()
	})

	scrollPane.Connect("key_release_event", func(window *gtk.ScrolledWindow, event *gdk.Event) {
		keyEvent := gdk.EventKeyNewFromEvent(event)
		keyEventState := keyEvent.State()

		if (keyEventState & (uint)(gdk.GDK_CONTROL_MASK|gdk.GDK_SHIFT_MASK)) == (uint)(gdk.GDK_CONTROL_MASK|gdk.GDK_SHIFT_MASK) {
			keyVal := keyEvent.KeyVal()

			if keyVal == gdk.KEY_D {
				scrollPane.Destroy()
			}
		}
	})

	return &filePane
}

func createFileContextMenu(filePane *FilePane) *gtk.Menu {
	openItem, _ := gtk.MenuItemNewWithLabel("Open")
	openItem.Connect("activate", func() {
		_, fullpath := filePane.getSelectedFile()
		if filePane.isSelectedFileADirectory() {
			filePane.SetPath(fullpath)
		} else {
			files.OpenFile(filePane.parentWindow, fullpath)
		}
	})

	deleteToTrashbinItem, _ := gtk.MenuItemNewWithLabel("Delete to trashbin")
	deleteToTrashbinItem.Connect("activate", func() {

		basename, fullpath := filePane.getSelectedFile()
		message := fmt.Sprintf("Do you really want to move the file '%s' into the trashbin?", basename)
		deleteToTrashbinQuestion := gtk.MessageDialogNew(filePane.parentWindow, gtk.DIALOG_DESTROY_WITH_PARENT, gtk.MESSAGE_QUESTION, gtk.BUTTONS_YES_NO, message)
		if deleteToTrashbinQuestion.Run() == gtk.RESPONSE_YES {
			wastebasket.Trash(fullpath)
		}

		deleteToTrashbinQuestion.Destroy()
	})

	menu, _ := gtk.MenuNew()
	menu.Append(openItem)
	separatorOne, _ := gtk.SeparatorMenuItemNew()
	menu.Append(separatorOne)
	menu.Append(deleteToTrashbinItem)

	/*openWithItem, _ := gtk.MenuItemNewWithLabel("Open with...")
	openWithItem.Connect("activate", func() {
		//TODO I might have to write new bindings first!
	})*/
	//menu.Append(openWithItem)

	return menu
}

func (filePane *FilePane) isSelectedFileADirectory() bool {
	selection, _ := filePane.fileTree.GetSelection()
	_, iter, ok := selection.GetSelected()
	if !ok {
		return false
	}

	selectedItem, _ := filePane.treeModel.GetValue(iter, columnIsDir)
	selectedItemAsGoValue, castError := selectedItem.GoValue()

	if castError != nil {
		return false
	}

	return selectedItemAsGoValue.(bool)
}

//getSelectedFile returns the basename and the full path of the selected file.
func (filePane *FilePane) getSelectedFile() (string, string) {
	selection, _ := filePane.fileTree.GetSelection()
	_, iter, ok := selection.GetSelected()
	if !ok {
		return "", ""
	}

	selectedItem, _ := filePane.treeModel.GetValue(iter, columnName)
	selectedItemAsGoValue, castError := selectedItem.GoValue()

	if castError != nil {
		return "", ""
	}

	selectedItemAsString := selectedItemAsGoValue.(string)
	return selectedItemAsString, filepath.Join(filePane.currentDirectory, selectedItemAsString)

}

func (filePane *FilePane) handleRowActivation() {
	_, selectedFileFullpath := filePane.getSelectedFile()
	fileInfo, fileError := os.Stat(selectedFileFullpath)
	if fileError != nil {
		return
	}

	if fileInfo.IsDir() {
		filePane.SetPath(selectedFileFullpath)
	} else {
		files.OpenFile(filePane.parentWindow, selectedFileFullpath)
	}
}

func createNameColumn() *gtk.TreeViewColumn {
	iconRenderer, _ := gtk.CellRendererPixbufNew()
	nameRenderer, _ := gtk.CellRendererTextNew()
	nameColumn, _ := gtk.TreeViewColumnNew()
	nameColumn.SetTitle("Name")
	nameColumn.PackStart(iconRenderer, false)
	nameColumn.PackEnd(nameRenderer, true)
	nameColumn.SetExpand(true)
	nameColumn.AddAttribute(iconRenderer, "pixbuf", columnIcon)
	nameColumn.AddAttribute(nameRenderer, "text", columnName)

	return nameColumn
}

func createSizeColumn() *gtk.TreeViewColumn {
	sizeRenderer, _ := gtk.CellRendererTextNew()
	sizeColumn, _ := gtk.TreeViewColumnNewWithAttribute("Size", sizeRenderer, "text", columnSize)

	return sizeColumn
}

//SetPath sets the current directory that the FilePane represents.
func (filePane *FilePane) SetPath(path string) {
	dirContent, errorReadingNotes := ioutil.ReadDir(path)

	if errorReadingNotes != nil {
		log.Fatalf("Error reading notes (%s).", errorReadingNotes.Error())
	}

	filePane.treeModel.Clear()

	//Add Item to go back by one directory
	if !(len(path) == 0 || path == "/") {
		modelIter := filePane.treeModel.Append()
		filePane.treeModel.SetValue(modelIter, columnName, "..")
		filePane.treeModel.SetValue(modelIter, columnIcon, GetFolderIcon())
	}

	//TODO Add workaround for sorting (Primary by dir / file and then alphabetical) as there are no sort_func bindings
	for _, fileInfo := range dirContent {
		modelIter := filePane.treeModel.Append()
		filePane.treeModel.SetValue(modelIter, columnName, fileInfo.Name())

		isFileDir := fileInfo.IsDir()
		fileSize := fileInfo.Size()

		//Symlinks have to be treated differently, we ignore errors though, as it isn't fatal if this fails.
		if (fileInfo.Mode() & os.ModeSymlink) == os.ModeSymlink {
			resolvedPath, evalutationError := filepath.EvalSymlinks(filepath.Join(path, fileInfo.Name()))
			if evalutationError == nil {
				symLinkedFile, statError := os.Stat(resolvedPath)
				if statError == nil {
					isFileDir = symLinkedFile.IsDir()
					fileSize = symLinkedFile.Size()
				}
			}
		}

		filePane.treeModel.SetValue(modelIter, columnIsDir, isFileDir)
		if isFileDir {
			filePane.treeModel.SetValue(modelIter, columnIcon, GetFolderIcon())
		} else {
			filePane.treeModel.SetValue(modelIter, columnIcon, GetPixbuf())
			filePane.treeModel.SetValue(modelIter, columnSize, files.ToHumanReadableFileSize(fileSize))
		}
	}

	filePane.currentDirectory = path
}

//GetRootWidget returns the root widget for the file pane. It doesn't matter of which type it is.
func (filePane *FilePane) GetRootWidget() *gtk.Widget {
	return filePane.rootWidget
}
