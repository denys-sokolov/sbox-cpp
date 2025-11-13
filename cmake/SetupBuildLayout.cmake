include_guard()

include(GNUInstallDirs)

# Output directory for archives
if(NOT DEFINED CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
  set(
    CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}"
  )
endif()

# Output directory for libraries
if(NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY)
  set(
    CMAKE_LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}"
  )
endif()

# Output directory for debug symbols
if(NOT DEFINED CMAKE_PDB_OUTPUT_DIRECTORY)
  set(
    CMAKE_PDB_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/debug"
  )
endif()

# Output directory for executables
if(NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
  set(
    CMAKE_RUNTIME_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}"
  )
endif()
