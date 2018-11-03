cmake_minimum_required (VERSION 3.5)

project(example)
set(CMAKE_MODULE_PATH  ${CMAKE_CURRENT_LIST_DIR})

add_library(example example.c)

add_library(interface_library INTERFACE)
target_link_libraries(example PRIVATE $<TARGET_NAME:interface_library>)

find_package(TIFF 4.0)
target_link_libraries(interface_library INTERFACE TIFF::TIFF)

find_package(Threads)
target_link_libraries(interface_library INTERFACE Threads::Threads)

find_package(ZLIB)
target_link_libraries(interface_library INTERFACE ZLIB::ZLIB)

include(GenerateConfig)
set(CONFIG_DATADIR "data")
set(CONFIG_)
generate_config("lib-config.in")

