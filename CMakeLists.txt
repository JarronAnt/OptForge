
cmake_minimum_required(VERSION 3.20)
project(OptForge VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(LLVM REQUIRED CONFIG)

# Ensure we're using LLVM 22.x
if(NOT LLVM_VERSION_MAJOR EQUAL 22)
    message(FATAL_ERROR
        "OptForge requires LLVM 22.x, found ${LLVM_PACKAGE_VERSION}"
    )
endif()

message(STATUS "Building OptForge against LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM CMake directory: ${LLVM_DIR}")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# Build the dynamically loadable LLVM pass plugin.
add_llvm_pass_plugin(OptForgePass
    src/IdentitySimplify.cpp
)

include(CTest)

if(BUILD_TESTING)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)

    find_program(LLVM_OPT NAMES opt
        HINTS "${LLVM_TOOLS_BINARY_DIR}"
              "${LLVM_INSTALL_PREFIX}/bin"
        REQUIRED
    )

    find_program(LLVM_FILECHECK NAMES FileCheck
        HINTS "${LLVM_TOOLS_BINARY_DIR}"
              "${LLVM_INSTALL_PREFIX}/bin"
        REQUIRED
    )

    foreach(TEST_NAME IN ITEMS identity safety)
        add_test(
            NAME "optforge_${TEST_NAME}"
            COMMAND "${Python3_EXECUTABLE}"
                "${PROJECT_SOURCE_DIR}/tests/run_filecheck.py"
                --opt "${LLVM_OPT}"
                --filecheck "${LLVM_FILECHECK}"
                --plugin "$<TARGET_FILE:OptForgePass>"
                --input "${PROJECT_SOURCE_DIR}/tests/${TEST_NAME}.ll"
        )
    endforeach()
endif()

