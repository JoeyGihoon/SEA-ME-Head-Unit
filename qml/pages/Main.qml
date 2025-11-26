import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    flags: Qt.FramelessWindowHint
    //visibility: Window.FullScreen
    width: 1024
    height: 600
    title: "TEAM5 HU"

    property color backgroundTint: Qt.rgba(1, 0, 0, 0) // 완전 투명 (아무 색도 안 입힘)
    property real backgroundSliderValue: 0.0

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/qml/images/dark-blue-product-background.jpg"   // 배경으로 쓰려는 이미지 경로
        fillMode: Image.PreserveAspectCrop // 화면 꽉 차게, 비율 유지
    }
    ColorOverlay {
        id: mainBackgroundOverlay
        anchors.fill: backgroundImage
        source: backgroundImage
        color: mainWindow.backgroundTint
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // --- 항상 보이는 Top Bar ---
    TopInfo
    {
        id: topBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
    }

    // --- 항상 보이는 Gear Bar ---
    GearWidget {
        id: gear_widget
        widthData: 100
        heightData: 540
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 20
    }

    // --- 오른쪽 컨텐츠 영역 ---
    Rectangle{
        id: contentArea
        color: "transparent"
        anchors.top: topBar.bottom
        anchors.topMargin: -35
        anchors.bottom: gear_widget.bottom
        anchors.left: gear_widget.right
        anchors.right: parent.right

        StackView{
            id: stackView
            anchors.fill: parent

            pushEnter: Transition {
                PropertyAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
            }
            pushExit: Transition {
                PropertyAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
            }
            popEnter: Transition {
                PropertyAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
            }
            popExit: Transition {
                PropertyAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
            }

            initialItem: Item{
                //anchors.fill: parent

                WeatherWidget{
                    id:weather_widget
                    anchors.top: parent.top
                    anchors.topMargin: -13
                    anchors.left: parent.left
                    anchors.leftMargin: -25

                    onClicked: stackView.push("qrc:/qml/pages/WeatherApplication.qml")
                }

                MapWidget {
                    id: map_widget
                    iconSource: "qrc:/qml/images/icon_maps.png"
                    title: "Map"
                    iconSize: 80
                    anchors.top: weather_widget.top
                    anchors.left: weather_widget.right
                    anchors.leftMargin: -35

                    onClicked: stackView.push("qrc:/qml/pages/MapApplication.qml")
                }

                YoutubeWidget{
                    id: youtube_widget
                    iconSource: "qrc:/qml/images/icon_youtube.png"
                    anchors.top: map_widget.top
                    anchors.left: map_widget.right
                    anchors.leftMargin: -35

                    onClicked: stackView.push("qrc:/qml/pages/YoutubeApplication.qml")
                }

                MusicWidget{
                    id: music_widget
                    iconSource: "qrc:/qml/images/icon_music.png"
                    anchors.top: youtube_widget.top
                    anchors.left: youtube_widget.right
                    anchors.leftMargin: -35

                    onClicked: stackView.push("qrc:/qml/pages/MusicApplication.qml")
                }

                ModeWidget{
                    id: mode_widget
                    iconSource: "qrc:/qml/images/icon_mode.png"
                    anchors.top: music_widget.top
                    anchors.left: music_widget.right
                    anchors.leftMargin: -35

                    onClicked: stackView.push(
                                   "qrc:/qml/pages/LightApplication.qml",
                                   { mainWindow: mainWindow }
                                )
                }
            }
        }
    }
}
