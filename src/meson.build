organiza_sources = [
  'files/fileutil.vala',
  'main.vala',
  'window.vala',
]

organiza_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
]

gnome = import('gnome')

organiza_sources += gnome.compile_resources('organiza-resources',
  'organiza.gresource.xml',
  c_name: 'organiza'
)

executable('organiza', organiza_sources,
  vala_args: '--target-glib=2.50',  dependencies: organiza_deps,
  install: true,
)
