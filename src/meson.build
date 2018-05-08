# These sources are shared with the main application and unit tests.
organiza_sources = files([
  'files/fileutil.vala',
  'window.vala',
])

organiza_main = files('main.vala')

# this finds the math library in a portable way
cc = meson.get_compiler('c')
math_dep = cc.find_library('m', required : true)

organiza_deps = [
  dependency('gio-2.0', version: '>= 2.48'),
  dependency('gtk+-3.0', version: '>= 3.18'),
  dependency('glib-2.0', version: '>= 2.48'),
  math_dep,
]

gnome = import('gnome')

organiza_sources += gnome.compile_resources('organiza-resources',
  'organiza.gresource.xml',
  c_name: 'organiza'
)

executable('organiza', organiza_sources, organiza_main,
  dependencies: organiza_deps,
  install: true,
)
