cmake_minimum_required (VERSION 3.5)
project(example VERSION 0.1 LANGUAGES C)
set(CMAKE_MODULE_PATH  ${CMAKE_CURRENT_LIST_DIR}/Modules)
include(GenerateLibConfig)

add_library(example example.c)
add_library(interface_library INTERFACE)
target_link_libraries(example PRIVATE interface_library)

find_package(Threads)
target_link_libraries(interface_library INTERFACE Threads::Threads)

# subdirectory example
# ---------------------
find_package(ZLIB)
target_link_libraries(interface_library INTERFACE ZLIB::ZLIB)
#
#add_library(submodule OBJECT submodule.c)
#target_include_directories(submodule PRIVATE ${ZLIB_INCLUDE_DIRS})
#target_sources(example PRIVATE $<TARGET_OBJECTS:submodule>)
# ---------------------

generate_lib_config(example interface_library ${CMAKE_CURRENT_SOURCE_DIR}/lib-config.in
                    ${CMAKE_CURRENT_BINARY_DIR}/example-config)
install(PROGRAMS example-config
        DESTINATION bin
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
