# Generate example-config shell script

There are sometimes produce `example-config` command that works like `pkg-config` 
to provide a build configurations, when you develop library and distribute.

This is a function to produce `example-config`.

## How to use?

1. Place cmake scripts under `Modules` folder in your project and add search path
in your `CMakeLists.txt` by setting `CMAKE_MODULE_PATH` variable.

2. Place `lib-config.in` template file in your project.

3. Include script using `include(GenearateConfig)` in your `CMakeLists.txt`

4. Set variable `CONFIG_DATADIR` to fit your project.

5. Call function `generate_config(<target_name> <output_filename>)`.

## Limitations

This module assumes you use a specific way to link external library with your project.
It is happened with CMake features and limitations.

* You should defines INTERFACE library and link all external libraries with it
  if you have several subfolders in your project.

