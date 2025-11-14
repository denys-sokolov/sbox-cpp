# Treat warnings on compile as errors
set(CMAKE_COMPILE_WARNING_AS_ERROR TRUE)

# Static runtime library type to use with MSVC ABI
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Position independent binaries
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)

# Postfix to append to the target file name
set(CMAKE_DEBUG_POSTFIX d)

# Enabe available and reasonable set of warning options
add_compile_options(
  /permissive- # Standards conformance
  /sdl # Enable additional security checks
  /w14242
  /w14254
  /w14263
  /w14265
  /w14287
  /w14296
  /w14311
  /w14545
  /w14546
  /w14547
  /w14549
  /w14555
  /w14619
  /w14640
  /w14826
  /w14905
  /w14906
  /w14928
  /W4
  /we4289
  /we4701
)

# Enable standard library hardening
if(USE_STL_HARDENING)
  add_compile_definitions(_MSVC_STL_HARDENING=1)
endif()

# Enable dynamic base and address space layout randomization
add_link_options(
  /DYNAMICBASE
  /LARGEADDRESSAWARE
)

# Enable binary size optimizations
add_compile_options(/Gy)
add_link_options(
  $<$<CONFIG:Release,RelWithDebInfo>:/INCREMENTAL:NO>
  $<$<CONFIG:Release,RelWithDebInfo>:/OPT:ICF>
  $<$<CONFIG:Release,RelWithDebInfo>:/OPT:REF>
)

# Set the default load flags used when the operating system resolves the
# statically linked imports of a module to LOAD_LIBRARY_SEARCH_SYSTEM32
add_link_options(/DEPENDENTLOADFLAG:0x800)

# Conan dependency provider
set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release)
set(CONAN_INSTALL_FLAGS "--build=missing")
set(
  CONAN_INSTALL_FLAGS_DEBUG
  "--profile:all=${CMAKE_CURRENT_LIST_DIR}/ConanProfileDebug"
)
set(
  CONAN_INSTALL_FLAGS_RELWITHDEBINFO
  "--profile:all=${CMAKE_CURRENT_LIST_DIR}/ConanProfileRelease"
)
