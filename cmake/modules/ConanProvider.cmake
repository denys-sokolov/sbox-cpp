#[=======================================================================[.rst:
ConanProvider
-------------

This module uses following values:

.. variable:: CONAN_EXECUTABLE

  Full path to ``conan`` executable.

.. variable:: CONAN_INSTALL_FLAGS

  Additional flags to be added when installing project dependencies.

.. variable:: CONAN_INSTALL_FLAGS_<CONFIG>

  Additional flags to be added when installing project dependencies for
  configuration <CONFIG>.

#]=======================================================================]

cmake_minimum_required(VERSION 3.25)

define_property(
  DIRECTORY
  PROPERTY CONAN_PROVIDER_SEARCH_PATH
  INHERITED
  BRIEF_DOCS
    "Semicolon-separated list of search paths for find_package."
)

macro(conan_provide_dependency ARG_METHOD)
  get_property(
    _CONAN_PROVIDER_SEARCH_PATH
    DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    PROPERTY CONAN_PROVIDER_SEARCH_PATH
  )

  find_package(${ARGN} BYPASS_PROVIDER HINTS ${_CONAN_PROVIDER_SEARCH_PATH})
endmacro()

# Register the Conan dependency provider
cmake_language(
  SET_DEPENDENCY_PROVIDER conan_provide_dependency
  SUPPORTED_METHODS
    FIND_PACKAGE
)

# Tell find_package() to try "Config" mode before "Module" mode
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

# Include Conan dependency installation logic
list(
  APPEND CMAKE_PROJECT_INCLUDE
  "${CMAKE_CURRENT_LIST_DIR}/ConanProvider/DepsInstall.cmake"
)
