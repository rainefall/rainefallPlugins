cmake_minimum_required(VERSION 3.14)

project(rainefallUpdater
  LANGUAGES C CXX
  VERSION "0.0.1")

set(SOURCES
    "src/main.cpp"

    "windows/resource.h"
    "windows/resource.rc"
    "windows/rainefallUpdater.manifest"
)

set(HEADERS
    "ext/include/miniz.h"
    "ext/include/zip.h"
)

set(INCLUDE_DIRS
    "ext/include"
)

include_directories(${INCLUDE_DIRS})
link_directories(${CMAKE_SOURCE_DIR}/ext/lib)
add_executable(Updater ${SOURCES} ${HEADERS})
target_link_libraries(Updater zip)