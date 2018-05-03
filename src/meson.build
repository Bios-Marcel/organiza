organiza_sources = [
  'files/fileutil.vala',
  'main.vala',
  'window.vala',
]

organiza_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('glib-2.0', version: '>= 2.50'),
]

gnome = import('gnome')

organiza_sources += gnome.compile_resources('organiza-resources',
  'organiza.gresource.xml',
  c_name: 'organiza'
)

executable('organiza', organiza_sources,
  dependencies: organiza_deps,
  # link in libm (math).
  # this seems necessary to have access to GLib.Math. Not sure why, but probaly a hack!
  link_args: '-lm',
  install: true,
)
