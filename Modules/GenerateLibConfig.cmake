# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt.

#[=======================================================================[.rst:
GenerateLibConfig
--------------

  Generate example-config shell script to provide build configuration and
  information for example library user.

.. command:: generate_lib_config

   ogenerate_lib_config(<project target> <interface target> <template filename>
                    <output filename>)

  Now `project target` is a target that is a typically shared library.
  `interface target` is a target that is defined by
  `add_library(interface_target INTERFACE)`
  command and link with dependency libraries using
  `target_link_libraries(interface_target INTERFACE <imported target>)`
  command.

  `template filename` is a template to use as input for `file(GENERATE)`
  command. Typical example is bundled in example project.
  `output filename` is an output generated by `file(GENARATE)` command.

.. note::
  A template file should have following variable to replaced.

  * "@CONFIG_LIBS@"   :  a value for `example-config --libs` that is a
                      LDFLAGS to use main target library.
                       a value may be such as `-lexample`

  * "@CONFIG_DEP_LIBS@" : a value for `example-config --dep-libs` that
                      is a CFLAGS when build main target library.
                       a value may be such as `-lz -lpng`

  * "@CONFIG_PREFIX@"  :  replaced with `CMAKE_INSTALL_PREFIX` or defult
                       `/usr/local/`

  * "@CONFIG_CFLAGS@" :  a value for `example-config --cflags`
                       that is a CFLAGS to use main target library.
                       a value may be such as `-I/usr/include`

  * "@CONFIG_DATADIR@" : a value for `example-config --data-dir` that is
                       `<prefix>/share/<target name>`

  * "@CONFIG_VERSION@" : replaced with a value fo `<target>_VERSION` variable.

.. note::
  CMake does not allow you to link library with a target which is not defined
  in same directory, it means large project need to use INTERFACE target
  as a conductor for dependent external library.
  In typial case, a project may have following scripts;

  ```
  add_library(example example.c)
  add_library(interface_library INTERFACE)
  target_link_libraries(example PRIVATE interface_library)
  ```
  In example, `example` is a main target and `interface_library` is a conductor
  for depenencies.

  In subdirectory, some component may build as OBJECT target and
  link into `example` target.

  ```
  add_library(submodule OBJECT submodule.c)
  find_package(Threads)
  find_package(ZLIB)
  target_include_directories(submodule PRIVATE ${Threads_INCLUDE_DIRS}
                             ${ZLIB_INCLUDE_DIRS})
  target_link_libraries(interface_library INTERFACE Threads::Threds ZLIB::ZLIB)
  ```

  In a main CMakeLists.txt
  ```
  target_sources(example $<TARGET_OBJECTS:submodule>)
  generate_lib_config(example interface_library lib-config.in lib-config)
  ```

.. note::
  CMake 3.13 and later support direct link to external libary in subdirectory
  using `target_link_libraries()` command.

  This command do not support this feature.

#]=======================================================================]

include(SelectImportedConfig)
include(SplitLibraryToCFlags)

function(generate_lib_config _target _link _template _output)
    # CONFIG_PREFIX, CONFIG_CFLAGS, CONFIG_DATADIR, CONFIG_LIBS
    if(NOT DEFINED CMAKE_INSTALL_PREFIX)
        set(CONFIG_PREFIX "/usr/local") # default
    else()
        set(CONFIG_PREFIX ${CMAKE_INSTALL_PREFIX})
    endif()
    set(CONFIG_CFLAGS "-I${CONFIG_PREFIX}/include")
    set(CONFIG_DATADIR "${CONFIG_PREFIX}/share/${_target}")
    if(CONFIG_PREFIX STREQUAL "/usr")
        set(CONFIG_LIBS "${CMAKE_LINK_LIBRARY_FLAG}${_target}")
    else()
        set(CONFIG_LIBS "${CMAKE_LIBRARY_PATH_FLAG}${CONFIG_PREFIX}/lib ${CMAKE_LINK_LIBRARY_FLAG}${_target}")
    endif()
    set(CONFIG_VERSION ${${_target}_VERSION})

    # CONFIG_DEP_LIBS
    set(_DEP_LIBS "")
    get_property(_LIBS TARGET "${_link}" PROPERTY INTERFACE_LINK_LIBRARIES)
    list(REMOVE_DUPLICATES _LIBS)
    foreach(_lib IN LISTS _LIBS)
        if(NOT TARGET ${_lib})
            # will be file path
            split_library_to_cflags("${_lib}" _res)
            if(_res)
                list(APPEND _DEP_LIBS "${_res}")
            endif()
        else() # will be IMPORTED TARGET
            get_property(_type TARGET ${_lib} PROPERTY TYPE)
            if(_type STREQUAL "INTERFACE_LIBRARY")
                # IMPORTED INTERFACE TARGET
                # We are only able to access INTERFACE_* property
                get_property(_res TARGET ${_lib} PROPERTY INTERFACE_LINK_LIBRARIES)
                if(_res)
                    split_library_to_cflags("${_imp}" _res)
                    list(APPEND _DEP_LIBS "${_res}")
                endif()
            elseif(_type STREQUAL "UNKNOWN_LIBRARY")
                # IMPORTED UNKOWN
                get_property(_res TARGET ${_lib} PROPERTY IMPORTED_CONFIGURATIONS SET)
                if(_res) # use imported target with configurations
                    select_imported_config(${_target} _conf)
                    if(NOT _conf)
                        set(_conf RELEASE)
                    endif()
                    string(TOUPPER ${_conf} _BT)
                    get_property(_imp TARGET ${_lib} PROPERTY IMPORTED_LOCATION_${_BT})
                    split_library_to_cflags("${_imp}" _res)
                    list(APPEND _DEP_LIBS "${_res}")
                else() # just use default location
                    get_property(_imp TARGET ${_lib} PROPERTY IMPORTED_LOCATION)
                    split_library_to_cflags("${_imp}" _res)
                    list(APPEND _DEP_LIBS "${_res}")
                endif()
            endif()
        endif()
    endforeach()
    string(REPLACE ";" " " CONFIG_DEP_LIBS "${_DEP_LIBS}")

    # Generate lib-config
    cmake_policy(PUSH)
    if(POLICY CMP0070)
        cmake_policy(SET CMP0070 NEW)
    endif()
    file(READ ${_template} LIB_CONFIG_CONTENT)
    string(CONFIGURE "${LIB_CONFIG_CONTENT}" LIB_CONFIG_CONTENT @ONLY)
    file(GENERATE OUTPUT ${_output} CONTENT "${LIB_CONFIG_CONTENT}")
    cmake_policy(POP)
endfunction()
