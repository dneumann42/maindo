# https://mesonbuild.com/GuiTutorial.html

project('maindo', 'c',
  version : '0.1',
  default_options : ['c_std=c23', 'warning_level=3'])

sdl_dep = dependency('sdl3')
sdl_ttf_dep = dependency('SDL3_ttf')
# for windows uncomment and use
# sdl_main_dep = dependency('sdl2main')

exe = executable('maindo', 'maindo.c', 'src/tables.c', 'src/sqlite3.c',
  win_subsystem: 'windows',
  dependencies: [ sdl_dep, sdl_ttf_dep ],
  install : true)

test('basic', exe)
