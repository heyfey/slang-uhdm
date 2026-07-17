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

add_library(slang_uhdm_obj_lib OBJECT
    src/UhdmExporter.cpp
    src/ModuleEmit.cpp
    src/ParamEmit.cpp
    src/StmtEmit.cpp
    src/TaskFuncEmit.cpp
    src/ExprEmit.cpp
    src/TypeEmit.cpp)
target_include_directories(slang_uhdm_obj_lib PUBLIC include)
target_link_libraries(slang_uhdm_obj_lib PUBLIC slang::slang uhdm::uhdm)

add_executable(slang_uhdm uhdm_main.cpp)
target_link_libraries(slang_uhdm PRIVATE slang_uhdm_obj_lib)
set_target_properties(slang_uhdm PROPERTIES OUTPUT_NAME "slang-uhdm")

install(TARGETS slang_uhdm RUNTIME DESTINATION bin)
