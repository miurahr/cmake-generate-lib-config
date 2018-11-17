# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt.

#[=======================================================================[.rst:
SplitLibraryToCflags
--------------------

  Convert full path of library into -L/usr/local -lz style cflags.

.. command:: split_library_to_cflags

  split_library_to_cflags(<library path> <output variable>)

#]=======================================================================]

function(split_library_to_cflags _lib _result)
    if(_lib)
        set(RESULT)
        get_filename_component(_lib_name ${_lib} NAME_WE)
        if(_lib_name STREQUAL "")
        else()
            string(REGEX REPLACE "^lib" "" _lib_name ${_lib_name})
            get_filename_component(_lib_dir ${_lib} PATH)
            if("${_lib_dir}" STREQUAL "")
                set(RESULT "${_lib_name}")
            else()
                if(_lib_dir MATCHES "${CMAKE_LIBRARY_ARCHITECTURE_REGEX}")
                    set(RESULT "${CMAKE_LINK_LIBRARY_FLAG}${_lib_name}")
                elseif(_lib_dir MATCHES "^/usr/lib$")
                    set(RESULT "${CMAKE_LINK_LIBRARY_FLAG}${_lib_name}")
                else()
                    set(RESULT "${CMAKE_LIBRARY_PATH_FLAG}${_lib_dir}")
                    list(APPEND RESULT "${CMAKE_LINK_LIBRARY_FLAG}${_lib_name}")
                endif()
            endif()
        endif()
        set(${_result} "${RESULT}" PARENT_SCOPE)
    endif()
endfunction()
