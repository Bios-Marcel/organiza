project('organiza', ['c', 'vala'],
  version: '0.1.0',
  meson_version: '>= 0.40.0',
)

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir('data')
subdir('src')
subdir('tests')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')

