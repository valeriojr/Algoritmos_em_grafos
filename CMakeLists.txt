cmake_minimum_required(VERSION 3.14)
project(Algoritmos_em_grafos)

set(CMAKE_CXX_STANDARD 14)

include_directories(include)

add_executable(dijkstra dijkstra.cpp)
add_executable(tarjan tarjan.cpp)
add_executable(bellmanFord bellmanFord.cpp)
add_executable(fordFulkerson fordFulkerson.cpp)