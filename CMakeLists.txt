# slang-uhdm: SystemVerilog -> UHDM exporter built on slang.
#
# Produces UHDM databases structurally identical to Surelog's folded output.
# Compatibility contract (the pin set every consumer must share):
#   UHDM    5523dfc    (v1.86-31)
#   Surelog cbdbea458c (v1.86-114, reference producer for convergence)
#   slang   master 2026-07 (v11.0 dev)
cmake_minimum_required(VERSION 3.20)
project(slang-uhdm VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(slang CONFIG REQUIRED)
find_package(UHDM CONFIG REQUIRED)

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

install(TARGETS slang_uhdm RUNTIME DESTINATION bin)
