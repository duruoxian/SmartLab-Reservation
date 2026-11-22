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

# Theme.qml 以 QML 单例注册；页面统一经 import SmartLab.ui 引用主题与公共组件。
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(SmartLab
    URI SmartLab.ui
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/PageShell.qml
        qml/NavSidebar.qml
        qml/InfoBanner.qml
        qml/EmptyState.qml
        qml/SectionCard.qml
        qml/ConfirmDialog.qml
        qml/PaginationBar.qml
        qml/HomePage.qml
        qml/FormField.qml
        qml/AuthPage.qml
        qml/ProfilePage.qml
        qml/RolePage.qml
        qml/EquipmentPage.qml
        qml/EquipmentDetailPage.qml
        qml/ReservationCreatePage.qml
        qml/MyReservationsPage.qml
        qml/ApprovalPage.qml
        qml/NotificationPage.qml
        qml/AdminPage.qml
        qml/StatsPage.qml
)
