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

    StackView{
        id: stackView
        anchors.fill: parent

        initialItem: Item{
            TopInfo {
                id: topBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }

            GearWidget {
                id: gear_widget
                widthData: 100
                heightData: 540
                anchors.left: parent.left
                // anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 20
            }

            WeatherWidget{
                id:weather_widget
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: gear_widget.right
                anchors.leftMargin: -25

                onClicked: stackView.push("qrc:/qml/pages/WeatherApplication.qml")
            }

            MapWidget {
                id: map_widget
                iconSource: "qrc:/qml/images/icon_maps.png"
                title: "Map"
                iconSize: 80
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: weather_widget.right
                anchors.leftMargin: -35

                onClicked: stackView.push("qrc:/qml/pages/MapApplication.qml")
            }

            YoutubeWidget{
                id: youtube_widget
                iconSource: "qrc:/qml/images/icon_youtube.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: map_widget.right
                anchors.leftMargin: -35

                onClicked: stackView.push("qrc:/qml/pages/YoutubeApplication.qml")
            }

            MusicWidget{
                id: music_widget
                iconSource: "qrc:/qml/images/icon_music.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: youtube_widget.right
                anchors.leftMargin: -35

                onClicked: stackView.push("qrc:/qml/pages/MusicApplication.qml")
            }

            ModeWidget{
                id: mode_widget
                iconSource: "qrc:/qml/images/icon_mode.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
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
