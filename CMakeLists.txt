cmake_minimum_required(VERSION 3.16)
project(hydra VERSION 0.0.1)

set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT hydra)

# option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)

find_package(Python REQUIRED COMPONENTS Interpreter Development)
# find_package(PythonLibs REQUIRED)

# list of chuck files
FILE(GLOB CK_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/../chuck/include/*.h
  )

FILE(GLOB readme
  "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
  )

set(Sources
  "Hydra.cpp"
  )

# target_include_directories(nlohmann PRIVATE "nlohmann")
FILE(GLOB NLOHMANN
  ${CMAKE_CURRENT_SOURCE_DIR}/nlohmann/json.hpp
  )

add_library(hydra SHARED ${CK_SOURCES} ${Sources} ${NLOHMANN})

set_target_properties(hydra PROPERTIES OUTPUT_NAME "Hydra.chug")
set_target_properties(hydra PROPERTIES PREFIX "")
set_target_properties(hydra PROPERTIES SUFFIX "")

target_compile_features(hydra PRIVATE cxx_std_17)


IF (WIN32)
    target_compile_definitions(hydra
      PUBLIC
      # USE_BUILTIN_FFT
      __PLATFORM_WINDOWS__
      # USE_PTHREADS
      )
ELSEIF(UNIX)
    target_compile_definitions(hydra
      PUBLIC
      # USE_BUILTIN_FFT
      __PLATFORM_LINUX__
      USE_PTHREADS
    ) 
ENDIF()

  
target_link_libraries(hydra PRIVATE Python::Python)

include_directories(${Python_INCLUDE_DIRS})
target_link_libraries(hydra ${PYTHON_LIBRARIES})
# I don't think this is necessary?
# SET(CMAKE_INSTALL_RPATH Python::Python)

# Include header directories
target_include_directories(hydra PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../chuck/include>
    $<INSTALL_INTERFACE:hydra
    )

# Install library
INSTALL(
  TARGETS hydra
  LIBRARY DESTINATION "~/.chuck/lib/"
  # LIBRARY DESTINATION ${CMAKE_INSTALL_RPATH}
  # ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  # RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )

IF (WIN32)
    message(POOP="%USERPROFILE%/Documents/chuck/chugins")
    add_custom_command(TARGET ${PROJECT_NAME}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "$<TARGET_FILE:hydra>"
      # "~/Documents/chuck/chugins"
      "%USERPROFILE%/Documents/chuck/chugins"
      )

ELSE()
    add_custom_command(TARGET ${PROJECT_NAME}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "$<TARGET_FILE:hydra>"
      "~/.chuck/lib/Hydra.chug")
ENDIF()

# rename to .chug file
add_custom_command(TARGET ${PROJECT_NAME}
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "$<TARGET_FILE:hydra>"
  "$<TARGET_FILE_DIR:hydra>/Hydra.chug")

# add_executable(test test.cpp)

