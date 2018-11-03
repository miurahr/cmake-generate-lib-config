cmake_minimum_required (VERSION 3.5)
project(example VERSION 0.1 LANGUAGES C)

if(POLICY CMP0070)
    cmake_policy(SET CMP0070 NEW)
endif()
set(CMAKE_MODULE_PATH  ${CMAKE_CURRENT_LIST_DIR}/Modules)

add_library(example example.c)
find_package(Threads)
find_package(ZLIB)

add_library(interface_library INTERFACE)
target_link_libraries(example PRIVATE interface_library)
target_link_libraries(interface_library INTERFACE Threads::Threads)
target_link_libraries(interface_library INTERFACE ZLIB::ZLIB)

include(GenerateConfig)
generate_config(example interface_library ${CMAKE_CURRENT_SOURCE_DIR}/lib-config.in example-config)
install(PROGRAMS example-config
        DESTINATION bin
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
