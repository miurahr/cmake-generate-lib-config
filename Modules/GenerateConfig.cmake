include(SelectImportedConfig)
include(SplitLibraryToCFlags)

function(generate_config _target _link _template _output)
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
    file(READ ${_template} LIB_CONFIG_CONTENT)
    string(CONFIGURE "${LIB_CONFIG_CONTENT}" LIB_CONFIG_CONTENT @ONLY)
    file(GENERATE OUTPUT ${_output} CONTENT "${LIB_CONFIG_CONTENT}")
endfunction()
