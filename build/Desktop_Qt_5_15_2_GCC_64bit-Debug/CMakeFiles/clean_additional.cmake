# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appTEAM5_HU_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appTEAM5_HU_autogen.dir/ParseCache.txt"
  "appTEAM5_HU_autogen"
  )
endif()
