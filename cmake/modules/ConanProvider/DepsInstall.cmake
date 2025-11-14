cmake_minimum_required(VERSION 3.25)

find_package(Conan 2.0 REQUIRED BYPASS_PROVIDER MODULE)

block(SCOPE_FOR VARIABLES)
  # Determine Conan recipe path
  if(EXISTS "${PROJECT_SOURCE_DIR}/conanfile.py")
    set(RECIPE_FILE "${PROJECT_SOURCE_DIR}/conanfile.py")
  elseif(EXISTS "${PROJECT_SOURCE_DIR}/conanfile.txt")
    set(RECIPE_FILE "${PROJECT_SOURCE_DIR}/conanfile.txt")
  else()
    message(VERBOSE "No Conan recipe found for ${PROJECT_NAME}.")
    return()
  endif()

  # Determine configuration types to use
  get_cmake_property(GENERATOR_IS_MULTI_CONFIG GENERATOR_IS_MULTI_CONFIG)
  if(GENERATOR_IS_MULTI_CONFIG)
    set(CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES})
  else()
    set(CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE})
  endif()

  if(NOT CONFIGURATION_TYPES)
    message(
      WARNING
      "No build configuration specified. "
      "Conan will not be run. "
      "For single-config generators, set CMAKE_BUILD_TYPE. "
      "For multi-config generators, set CMAKE_CONFIGURATION_TYPES."
    )
    return()
  endif()

  list(TRANSFORM CONFIGURATION_TYPES TOUPPER)

  set(SEARCH_PATH)
  foreach(CONFIG IN LISTS CONFIGURATION_TYPES)
    # Run conan install for the given configuration
    execute_process(
      COMMAND
        "${Conan_EXECUTABLE}" install ${CONAN_INSTALL_FLAGS}
        ${CONAN_INSTALL_FLAGS_${CONFIG}} "-of=${PROJECT_BINARY_DIR}/ConanFiles"
        "--format=json" "${RECIPE_FILE}"
      WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
      OUTPUT_VARIABLE COMMAND_OUTPUT_JSON
      COMMAND_ECHO STDOUT
      COMMAND_ERROR_IS_FATAL ANY
    )

    # Parse the generators folder from the JSON output and convert to CMake path
    # gersemi: off
    string(JSON SEARCH_DIR GET "${COMMAND_OUTPUT_JSON}" graph nodes 0 generators_folder)
    cmake_path(CONVERT "${SEARCH_DIR}" TO_CMAKE_PATH_LIST SEARCH_DIR NORMALIZE)
    # gersemi: on

    # Add the generators folder to the search path
    list(APPEND SEARCH_PATH "${SEARCH_DIR}")
  endforeach()

  # Add Conan recipe to configuration process dependencies
  set_property(
    DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    APPEND
    PROPERTY
      CMAKE_CONFIGURE_DEPENDS
        "${RECIPE_FILE}"
  )

  # Save unique search paths as a directory property
  list(REMOVE_DUPLICATES SEARCH_PATH)
  set_property(
    DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    PROPERTY
      CONAN_PROVIDER_SEARCH_PATH
        "${SEARCH_PATH}"
  )
endblock()
