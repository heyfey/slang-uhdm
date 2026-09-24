# slang-uhdm: SystemVerilog -> UHDM exporter built on slang.
#
# Produces UHDM databases structurally identical to Surelog's folded output.
# The dependencies are pinned by the submodules under third_party/:
#   third_party/Surelog                  Surelog (the reference producer)
#   third_party/Surelog/third_party/UHDM UHDM as Surelog pins it: the linked
#                                        library, the schema, and uhdm-cmp
#   third_party/slang                    the slang frontend
# By default both libraries are built in-tree from those submodules, so one
# `git submodule update --init --recursive` + cmake gives a reproducible
# binary. -DSLANG_UHDM_USE_SYSTEM_DEPS=ON uses installed packages instead
# (find_package via CMAKE_PREFIX_PATH); the pins are then the operator's job.
cmake_minimum_required(VERSION 3.20)
project(slang-uhdm VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(SLANG_UHDM_USE_SYSTEM_DEPS
       "Use installed slang and UHDM packages instead of the third_party submodules" OFF)
if(SLANG_UHDM_USE_SYSTEM_DEPS)
    find_package(slang CONFIG REQUIRED)
    find_package(UHDM CONFIG REQUIRED)
else()
    set(_su_slang ${CMAKE_CURRENT_SOURCE_DIR}/third_party/slang)
    set(_su_uhdm ${CMAKE_CURRENT_SOURCE_DIR}/third_party/Surelog/third_party/UHDM)
    foreach(_d ${_su_slang}/CMakeLists.txt ${_su_uhdm}/CMakeLists.txt
                ${_su_uhdm}/third_party/capnproto/CMakeLists.txt)
        if(NOT EXISTS ${_d})
            message(FATAL_ERROR "missing ${_d}: run `git submodule update --init --recursive` "
                                "(or configure with -DSLANG_UHDM_USE_SYSTEM_DEPS=ON)")
        endif()
    endforeach()
    # slang: a subproject builds only the library (no tools, tests, install).
    set(SLANG_INCLUDE_TOOLS OFF CACHE BOOL "" FORCE)
    set(SLANG_INCLUDE_TESTS OFF CACHE BOOL "" FORCE)
    set(SLANG_INCLUDE_INSTALL OFF CACHE BOOL "" FORCE)
    add_subdirectory(${_su_slang} EXCLUDE_FROM_ALL)
    # UHDM: the same commit Surelog builds against; its capnproto rides along.
    set(UHDM_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    set(UHDM_WITH_PYTHON OFF CACHE BOOL "" FORCE)
    add_subdirectory(${_su_uhdm})
    if(NOT TARGET uhdm::uhdm)
        add_library(uhdm::uhdm ALIAS uhdm)
    endif()
endif()

# share/builtin.sv is Surelog's Builtin::addBuiltinClasses() source, extracted
# byte for byte (the UHDM line:column spans depend on the exact text). Embed it
# so --builtins needs no runtime data file.
set(BUILTIN_SV_SRC ${CMAKE_CURRENT_SOURCE_DIR}/share/builtin.sv)
set(BUILTIN_SV_HDR ${CMAKE_CURRENT_BINARY_DIR}/generated/BuiltinSv.h)
file(READ ${BUILTIN_SV_SRC} BUILTIN_SV_TEXT)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/BuiltinSv.h.in ${BUILTIN_SV_HDR} @ONLY)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${BUILTIN_SV_SRC})

add_library(slang_uhdm_obj_lib OBJECT
    src/UhdmExporter.cpp
    src/ModuleEmit.cpp
    src/ParamEmit.cpp
    src/StmtEmit.cpp
    src/TaskFuncEmit.cpp
    src/ExprEmit.cpp
    src/TypeEmit.cpp)
target_include_directories(slang_uhdm_obj_lib PUBLIC include ${CMAKE_CURRENT_BINARY_DIR}/generated)
target_link_libraries(slang_uhdm_obj_lib PUBLIC slang::slang uhdm::uhdm)

add_executable(slang_uhdm uhdm_main.cpp)
target_link_libraries(slang_uhdm PRIVATE slang_uhdm_obj_lib)
set_target_properties(slang_uhdm PROPERTIES OUTPUT_NAME "slang-uhdm")

# uhdm-strictcmp: uhdm-cmp's verdict first, then the judge-blind fields
# (tools/uhdm-strictcmp/uhdm-strictcmp.cpp). Measurement tool for the sweep.
add_executable(uhdm_strictcmp tools/uhdm-strictcmp/uhdm-strictcmp.cpp)
target_link_libraries(uhdm_strictcmp PRIVATE uhdm::uhdm)
set_target_properties(uhdm_strictcmp PROPERTIES OUTPUT_NAME "uhdm-strictcmp")

install(TARGETS slang_uhdm uhdm_strictcmp RUNTIME DESTINATION bin)
