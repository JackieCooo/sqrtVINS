cmake_minimum_required(VERSION 3.16)

# Find ros dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(cv_bridge REQUIRED)

# Describe ROS project
option(ENABLE_ROS "Enable or disable building with ROS (if it is found)" ON)
if (NOT ENABLE_ROS)
    message(FATAL_ERROR "Build with ROS1.cmake if you don't have ROS.")
endif ()
add_definitions(-DROS_AVAILABLE=2)

option(USE_FLOAT "Use float version when built" ON)
if (USE_FLOAT)
    add_definitions(-DUSE_FLOAT=1)
endif ()

option(BUILD_TESTS "Enable test demo build" OFF)

# Include our header files
include_directories(
        src
        ${EIGEN3_INCLUDE_DIR}
        ${Boost_INCLUDE_DIRS}
)

# Set link libraries used by all binaries
list(APPEND thirdparty_libraries
        ${Boost_LIBRARIES}
        ${OpenCV_LIBRARIES}
)

##################################################
# Make the core library
##################################################

list(APPEND LIBRARY_SOURCES
        src/dummy.cpp
        src/cpi/CpiV1.cpp
        src/cpi/CpiV2.cpp
        src/sim/BsplineSE3.cpp
        src/track/TrackBase.cpp
        src/track/TrackAruco.cpp
        src/track/TrackDescriptor.cpp
        src/track/TrackKLT.cpp
        src/track/TrackSIM.cpp
        src/types/Landmark.cpp
        src/feat/Feature.cpp
        src/feat/FeatureDatabase.cpp
        src/feat/FeatureInitializer.cpp
        src/utils/print.cpp
)
add_library(${PROJECT_NAME} SHARED ${LIBRARY_SOURCES})
ament_target_dependencies(${PROJECT_NAME} PUBLIC rclcpp cv_bridge)
target_link_libraries(${PROJECT_NAME} PUBLIC ${thirdparty_libraries})
target_include_directories(${PROJECT_NAME} PUBLIC src/)
install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
        PUBLIC_HEADER DESTINATION include/${PROJECT_NAME}
)
install(DIRECTORY src/
        DESTINATION include/${PROJECT_NAME}
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)
ament_export_include_directories(include/${PROJECT_NAME})
ament_export_libraries(${PROJECT_NAME})

##################################################
# Make binary files!
##################################################

if(BUILD_TESTS)
    # TODO: UPGRADE THIS TO ROS2 AS ANOTHER FILE!!
    #if (catkin_FOUND AND ENABLE_ROS)
    #    add_executable(test_tracking src/test_tracking.cpp)
    #    target_link_libraries(test_tracking ${PROJECT_NAME} ${thirdparty_libraries})
    #endif ()

    add_executable(test_webcam src/test_webcam.cpp)
    ament_target_dependencies(test_webcam rclcpp cv_bridge)
    target_link_libraries(test_webcam ${PROJECT_NAME} ${thirdparty_libraries})
    install(TARGETS test_webcam DESTINATION lib/${PROJECT_NAME})

    add_executable(test_profile src/test_profile.cpp)
    ament_target_dependencies(test_profile rclcpp cv_bridge)
    target_link_libraries(test_profile ${PROJECT_NAME} ${thirdparty_libraries})
    install(TARGETS test_profile DESTINATION lib/${PROJECT_NAME})
endif(BUILD_TESTS)

# finally define this as the package
ament_package()
