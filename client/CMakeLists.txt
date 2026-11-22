cmake_minimum_required(VERSION 3.22)
project(SmartLabReservation VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick QuickControls2 Network)
qt_add_executable(SmartLab WIN32
    src/main.cpp
    src/ApiClient.h src/ApiClient.cpp
    src/UserViewModel.h src/UserViewModel.cpp
)
target_link_libraries(SmartLab PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Network)
qt_add_resources(SmartLab "smartlab_qml" PREFIX "/" FILES
    qml/Main.qml
    qml/AuthPage.qml
    qml/ProfilePage.qml
    qml/RolePage.qml
    qml/FormField.qml
)
