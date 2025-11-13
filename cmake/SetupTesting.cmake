include_guard(GLOBAL)

option(BUILD_TESTING "Build the testing tree." ON)

if(BUILD_TESTING)
  enable_testing()
endif()
