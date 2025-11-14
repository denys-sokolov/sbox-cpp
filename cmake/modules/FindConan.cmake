#[=======================================================================[.rst:
FindConan
---------

Find Conan, software package manager tool.

The following variables are defined by this module:

.. variable:: Conan_FOUND

  True if ``conan`` executable was found.

.. variable:: Conan_EXECUTABLE

  Full path to ``conan`` executable.

.. variable:: Conan_VERSION

  The version reported by ``conan --version``.

#]=======================================================================]

include(FindPackageHandleStandardArgs)

function(_find_conan_get_version ARG_OUT_VAR ARG_EXECUTABLE)
  # gersemi: ignore

  execute_process(
    COMMAND
      "${ARG_EXECUTABLE}" --version
    OUTPUT_VARIABLE COMMAND_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE COMMAND_RESULT
    ERROR_QUIET
  )

  if(NOT COMMAND_RESULT EQUAL 0)
    set(${ARG_OUT_VAR} PARENT_SCOPE)
    return()
  endif()

  string(
    REGEX MATCH
    [[[0-9]+\.[0-9]+\.[0-9]+]]
    VERSION_RESULT
    "${COMMAND_OUTPUT}"
  )
  set(${ARG_OUT_VAR} "${VERSION_RESULT}" PARENT_SCOPE)
endfunction()

function(_find_conan_version_validator ARG_OUT_VAR ARG_EXECUTABLE)
  # gersemi: ignore

  if(NOT DEFINED Conan_FIND_VERSION)
    set(${ARG_OUT_VAR} TRUE PARENT_SCOPE)
    return()
  endif()

  _find_conan_get_version(CANDIDATE_VERSION "${ARG_EXECUTABLE}")
  if(NOT CANDIDATE_VERSION)
    set(${ARG_OUT_VAR} FALSE PARENT_SCOPE)
    return()
  endif()

  find_package_check_version(
    "${CANDIDATE_VERSION}"
    CHECK_RESULT
    HANDLE_VERSION_RANGE
  )
  set(${ARG_OUT_VAR} ${CHECK_RESULT} PARENT_SCOPE)
endfunction()

find_program(
  Conan_EXECUTABLE
  NAMES
    conan
  HINTS ENV VIRTUAL_ENV
  PATH_SUFFIXES "bin" "Scripts"
  DOC "Path to Conan executable"
  VALIDATOR _find_conan_version_validator
)
mark_as_advanced(Conan_EXECUTABLE)

if(Conan_EXECUTABLE)
  _find_conan_get_version(Conan_VERSION "${Conan_EXECUTABLE}")
endif()

find_package_handle_standard_args(
  Conan
  REQUIRED_VARS
    Conan_EXECUTABLE
  VERSION_VAR Conan_VERSION
  HANDLE_VERSION_RANGE
)
