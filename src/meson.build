# These sources are shared with the min application and unit tests.
organiza_sources = [
  'files/fileutil.vala',
  'window.vala',
]

organiza_deps = [
  dependency('gio-2.0', version: '>= 2.48'),
  dependency('gtk+-3.0', version: '>= 3.18'),
  dependency('glib-2.0', version: '>= 2.48'),
]

gnome = import('gnome')

organiza_sources += gnome.compile_resources('organiza-resources',
  'organiza.gresource.xml',
  c_name: 'organiza'
)

executable('organiza', organiza_sources, 'main.vala',
  dependencies: organiza_deps,
  # link in libm (math).
  # this seems necessary to have access to GLib.Math. Not sure why ...
  link_args: '-lm',
  install: true,
)

fileutil = executable( 'fileutiltest',
  'files/fileutiltest.vala',
  organiza_sources,
  dependencies:organiza_deps,
  link_args: '-lm',
)
test('Testing file utilities.', fileutil)
