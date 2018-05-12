# Organiza
[![CircleCI](https://circleci.com/gh/Bios-Marcel/Organiza/tree/master.svg?style=svg)](https://circleci.com/gh/Bios-Marcel/Organiza/tree/master)

## Description
An attempt at writing a lightweight file manager for GTK3 using vala.

## Goals
* Focus on keyboard navigation
* Lightweight UI
  > The plan is to not overload the UI, therefore not every action will have a clickable item on the UI, but be bound to a keyboard shortcut instead
* Customizable keybindings
* Minimal configuration possibilities (finding the best possible defaults, whereas best means most useful to as many people as possible)
* Simple keybinding overview 
* The usual stuff
  * Delete file(s)/folder(s)
  * Copy file(s)/folder(s)
  * Move file(s)/folder(s)
  * Create file(s)/folder(s)
* Creation of links
* Triggering different actions per drag and drop
* Undo / Redo
* Controlling file permissions
* Listview for folders/files
  * Optionally display details (Date, size and so on)
* Multiple views
* Hide dotfiles
* Bookmarks
  * keybindings for bookmarks
* Overview of available drives
* image thumbnails

## How to build

In order to build an executable, you first have to satisfy the dependencies:

Those can be found in [`meson.build` located at `/src`](https://github.com/Bios-Marcel/Organiza/blob/b51fd6b72bb6702ac0d53bdc8eac23295f9ba2a5/src/meson.build#L13).

After downloading necessary dependencies you have to do the following:

1. Navigate into the root folder
```bash
cd /path/to/Organiza/
```
2. Create and configure the build directory
```bash
meson build
```
3. Start the build using the previously created build-directory
```bash
ninja -Cbuild
```

or

3. Use `ninja`s `install` command
```
sudo ninja install
```

The executable file will be located at `build/src` and is called `organiza`.

## Roadmap

### 0.0.1
#### Application
- [x] Displaying the file hierarchy
- [x] Navigation by mouse and keyboard
  - [x] Up and down by keyboard
  - [x] Up and down by mouse
- [x] React to file changes and update ui
#### Development
- [x] Run build on commit
- [x] Unit tests
  - [x] Build Integration

### 0.0.2

- [ ] Useful / non-annoying default sorting
- [ ] Change sorting by clicking column headers
- [ ] Jump to top by `POS1` and to bottom by `END`
- [ ] Open files
- [ ] Create new files / folders
- [ ] Overview of drives (a folder above `/` that shows all drives as list entries)

## How do i work on it best?
### Visual Studio Code

For optimal experience install the following extensions:

* [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight)
* [Uncrustify](https://marketplace.visualstudio.com/items?itemName=LaurentTreguier.uncrustify)
* [Vala Code](https://marketplace.visualstudio.com/items?itemName=thiagoabreu.vala)