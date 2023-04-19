cmake_minimum_required(VERSION 3.0.0)

# Get the name of the containing folder
get_filename_component(PROJECT_DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" PROJECT_NAME ${PROJECT_DIR_NAME})

project(${PROJECT_NAME} VERSION 0.1.0)


message("---------------CMake: Configure START---------------")



# Set up cross compilation
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)


#set compiler
set(CMAKE_C_COMPILER /usr/bin/arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/arm-linux-gnueabihf-g++)
set(CMAKE_AR arm-linux-gnueabihf-gcc-ar)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_Linker)

include_directories(
           ${CMAKE_SOURCE_DIR}/ntios/inc/
           ${CMAKE_SOURCE_DIR}/ntios/libraries/
           ${CMAKE_SOURCE_DIR}/inc
           ${CHROOT_INCLUDE_PATHS}
)

file(GLOB_RECURSE SRC_FILES "src/*.cpp")
file(GLOB_RECURSE LIBRARIES_FILES "${CMAKE_SOURCE_DIR}/ntios/libraries/*.cpp")

add_executable(${PROJECT_NAME} 
               #${CMAKE_SOURCE_DIR}/src/main.cpp
               ${SRC_FILES}
               ${LIBRARIES_FILES}
               ${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.cpp)

message("${CMAKE_SOURCE_DIR}/ntios/libs/")

target_link_options( ${PROJECT_NAME} PRIVATE -L${CMAKE_SOURCE_DIR}/ntios/libs/ -L/usr/lib/arm-linux-gnueabihf -Wl,-rpath=${CMAKE_SOURCE_DIR}/ntios/libs/)


target_link_libraries(  ${PROJECT_NAME} PRIVATE 
                        ntios_beep
                        ntios_button
                        ntios_io
                        ntios_fd 
                        ntios_pat
                        ntios_pmux
                        ntios_romfile
                        ntios_ssi
                        ntios_sys
                        ntios_syscalls
                        ntios_threads
                        gpiod
                        pthread rt)

set(TIOS_RESOURCES "${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.cpp")

add_custom_command(OUTPUT ${TIOS_RESOURCES}
COMMAND ${CMAKE_SOURCE_DIR}/ntios/prep_resources.sh  ${CMAKE_CURRENT_SOURCE_DIR}/resources/ ${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.cpp
COMMENT "Preparing Resources")


add_custom_target(prep_resources ${PROJECT_NAME} DEPENDS ${TIOS_RESOURCES}  )


#we use fpermisive because tios is permissive. The good thing here is we will get a warning if we do some implicit castings which are dangerous. 
target_compile_options(${PROJECT_NAME} PUBLIC -include ${CMAKE_SOURCE_DIR}/ntios/inc/threads/ntios_includes.h -fpermissive)
#target_compile_options(${PROJECT_NAME} PUBLIC -include ${CMAKE_SOURCE_DIR}/ntios/inc/threads/ntios_includes.h )


message("---------------CMake: Configure END---------------")