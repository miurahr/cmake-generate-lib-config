# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt.

#[=======================================================================[.rst:
SelectImportedConfig
--------------------

  Select a preferred imported configuration from a target.

.. command:: select_imported_config

  select_imported_config(<target name> <output variable>)

  At first we see `MAP_IMPORTED_CONFIG_${CMAKE_BUILD_TYPE}` property for
  target. If it exist, return the property value in output variable.
  Typically it may be RELEASE or DEBUG.

  Otherwise, we assume a target is imported, then check `IMPORTED_CONFIGURATIONS`

.. note::

  We select configuration by making list of configurations in order of preference,
  starting with ${CMAKE_BUILD_TYPE} and ending with the retrieved configuration.
  it is an order
  ``${CMAKE_BUILD_TYPE}  RELWITHDEBINFO RELEASE DEBUG <IMPORTED CONFIGURATION>``

#]=======================================================================]

function(select_imported_config target outvar)
    get_target_property(imported_conf ${target} MAP_IMPORTED_CONFIG_${CMAKE_BUILD_TYPE})
    if (NOT imported_conf)
        get_target_property(imported_conf ${target} IMPORTED_CONFIGURATIONS)
        set(preferred_confs ${CMAKE_BUILD_TYPE})
        list(GET imported_conf 0 _fallback_conf)
        list(APPEND preferred_confs RELWITHDEBINFO RELEASE DEBUG ${_fallback_conf})
        cmake_policy(PUSH)
        cmake_policy(SET CMP0057 NEW) # support IN_LISTS
        foreach (_conf IN LISTS preferred_confs)
            if (${_conf} IN_LIST imported_conf)
               set(imported_conf ${_conf})
               break()
            endif()
        endforeach()
        cmake_policy(POP)
    endif()
    set(${outvar} ${imported_conf} PARENT_SCOPE)
endfunction()

