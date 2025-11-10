cmake_minimum_required(VERSION 3.16)

project(TEAM5_HU VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1) Qt5 컴포넌트 찾기 (필요한 모듈 추가 가능)
find_package(Qt5 5.15 REQUIRED COMPONENTS
  Quick
  Qml
  QuickControls2
  WebEngine
  WebEngineCore
  WebChannel
)

# 2) 실행 파일
add_executable(appTEAM5_HU
    main.cpp
    mapController.h
    mapcontroller.cpp
    weather.cpp
    weather.h
    youtubeController.cpp
    youtubeController.h
    imageExtractor.cpp
    imageExtractor.h
    usbscanner.cpp
    usbscanner.h



)

# 3) QML을 qrc로 묶기
qt5_add_resources(QML_RES qml.qrc)
target_sources(appTEAM5_HU PRIVATE ${QML_RES})

# 4) 링크
target_link_libraries(appTEAM5_HU
    PRIVATE
      Qt5::Quick
      Qt5::Qml
      Qt5::QuickControls2
      Qt5::WebEngine
      Qt5::WebEngineCore
      Qt5::WebChannel
)

# 5) 설치 규칙 (옵션)
include(GNUInstallDirs)
install(TARGETS appTEAM5_HU
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
