# ~~~
# slang-uhdm: UHDM exporter tool
# Requires an installed UHDM package (anchor commit 5523dfc / v1.86-31);
# the tool is skipped silently when UHDM is not available so the regular
# slang build is unaffected.
# ~~~

find_package(UHDM CONFIG QUIET)
if(NOT UHDM_FOUND)
  message(STATUS "UHDM package not found: skipping slang-uhdm tool")
  return()
endif()
message(STATUS "UHDM found (${UHDM_VERSION}): building slang-uhdm")

add_library(slang_uhdm_obj_lib OBJECT src/UhdmExporter.cpp)
target_include_directories(slang_uhdm_obj_lib PUBLIC include)
target_link_libraries(slang_uhdm_obj_lib PUBLIC slang::slang uhdm::uhdm)

add_executable(slang_uhdm uhdm_main.cpp)
add_executable(slang::uhdm ALIAS slang_uhdm)
target_link_libraries(slang_uhdm PRIVATE slang_uhdm_obj_lib)
set_target_properties(slang_uhdm PROPERTIES OUTPUT_NAME "slang-uhdm")

if(SLANG_INCLUDE_INSTALL)
  install(TARGETS slang_uhdm RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
