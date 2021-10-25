cmake_minimum_required(VERSION 3.6)

project(cpp-toolbox)

set(ENGINE_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_MODULE_PATH ${ENGINE_ROOT_PATH}/cmake/Modules/)

message(STATUS ${CMAKE_MODULE_PATH})

# prevent in-source-build
include("PreventInSourceBuilds")

include("utils")
include("compile_utils")

init_build()


compile_include("Main")
compile_include("FixedPoint")

target_link_libraries("Main" "FixedPoint")