# Organiza

[![builds.sr.ht status](https://builds.sr.ht/~biosmarcel/Organiza/arch.yml.svg)](https://builds.sr.ht/~biosmarcel/Organiza/arch.yml?)

## Description

This is an attempt at writing a file manager that suits my needs. The app
will not have much mouse support, instead it will try to have intuitive
keyboard shortcuts.

If you want to know how to use this application, [check out the wiki](https://github.com/Bios-Marcel/organiza/wiki).

## How to build

In order to build an executable, you first have to satisfy the dependencies:

* GTK+3
* vte-2.91
* GLib-2.0
* vala
* meson
* ninja

After downloading necessary dependencies you have to do the following:

```sh
cd /path/to/organiza/  #Navigate into project directory
meson build            #Create and configure build folder at ./build
ninja -Cbuild          #Compile using the previously created buildfolder
```

The executable file will be located at `build/src` and is called `organiza`.

Alternatively you can also install the binary using:

```sh
cd /path/to/organiza/build  #Navigate into project directory
sudo ninja install          #Intall application on your system
```

## How do I work on it best

I suggest you use VS Code, as that is what I am using.

For an optimal experience install the following extensions:

* [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight)
* [Uncrustify](https://marketplace.visualstudio.com/items?itemName=LaurentTreguier.uncrustify)
* [Vala Code](https://marketplace.visualstudio.com/items?itemName=thiagoabreu.vala)
* [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
