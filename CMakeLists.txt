cmake_minimum_required(VERSION 3.16)
project(test)

find_package(Python REQUIRED Development)

add_executable(test test.cpp)
target_link_libraries(test PRIVATE Python::Python)
