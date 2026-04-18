cmake_minimum_required (VERSION 2.6)
project (65816)

include(ExternalProject)

option(BUILD_SMOKE_TEST "Build and run the in-repo 65816 smoke test" OFF)

ExternalProject_Add(
        simple-logger
        PREFIX "${PROJECT_SOURCE_DIR}/simple-logger"
        GIT_REPOSITORY https://github.com/FrancescoRigoni/Simple-Logger.git
        INSTALL_COMMAND "")

# Retrieve simple-logger sources location
ExternalProject_Get_Property(simple-logger source_dir)
set(SIMPLE_LOGGER_SRC ${source_dir})

# Retrieve simple-logger binaries location
ExternalProject_Get_Property(simple-logger binary_dir)
set(SIMPLE_LOGGER_BIN ${binary_dir})

if (CMAKE_VERSION VERSION_LESS "3.1")
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set (CMAKE_CXX_FLAGS "--std=gnu++14 ${CMAKE_CXX_FLAGS}")
endif ()
else ()
    set (CMAKE_CXX_STANDARD 14)
endif ()

# Add paths for linker
link_directories(${SIMPLE_LOGGER_BIN})

# All warnings on
set (CMAKE_CXX_FLAGS "-Wall ${CMAKE_CXX_FLAGS}")
file(GLOB sources_65816 src/*.cpp src/opcodes/*.cpp)

add_library(65816 ${sources_65816})
add_dependencies(65816 simple-logger)
target_link_libraries(65816 SimpleLogger)
target_include_directories(65816 PRIVATE ${PROJECT_SOURCE_DIR}/include ${SIMPLE_LOGGER_SRC})

if (BUILD_SMOKE_TEST)
    find_program(TASS64_EXECUTABLE NAMES 64tass)
    if (NOT TASS64_EXECUTABLE)
        message(FATAL_ERROR "64tass not found but BUILD_SMOKE_TEST is ON")
    endif ()

    set(SMOKE_ASM ${PROJECT_SOURCE_DIR}/tests/smoke/65816_smoke.asm)
    set(SMOKE_BIN ${PROJECT_BINARY_DIR}/65816_smoke.bin)

    add_custom_command(
            OUTPUT ${SMOKE_BIN}
            COMMAND ${TASS64_EXECUTABLE} -B --m65816 -f -o ${SMOKE_BIN} ${SMOKE_ASM}
            DEPENDS ${SMOKE_ASM}
            COMMENT "Assembling 65816 smoke program")

    add_custom_target(assemble_65816_smoke DEPENDS ${SMOKE_BIN})

    add_executable(run65816_smoke tests/smoke/run65816_smoke.cpp)
    add_dependencies(run65816_smoke simple-logger assemble_65816_smoke)
    target_link_libraries(run65816_smoke 65816 SimpleLogger)
    target_include_directories(run65816_smoke PRIVATE ${PROJECT_SOURCE_DIR}/include ${SIMPLE_LOGGER_SRC})

    add_custom_target(
            smoke65816
            COMMAND run65816_smoke ${SMOKE_BIN}
            DEPENDS run65816_smoke assemble_65816_smoke
            COMMENT "Running 65816 smoke test")
endif ()
