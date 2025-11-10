import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1024
    height: 600
    title: "TEAM5 HU"

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/qml/images/dark-blue-product-background.jpg"   // 배경으로 쓰려는 이미지 경로
        fillMode: Image.PreserveAspectCrop // 화면 꽉 차게, 비율 유지
    }

    // Image {
    //     id: car
    //     width: 700
    //     height: parent.height
    //     anchors.right: parent.right
    //     anchors.top: parent.top
    //     anchors.margins: -100
    //     anchors.topMargin: 50
    //     source: "qrc:qml/images/car.png"
    //     fillMode: Image.PreserveAspectFit
    //     smooth: true
    // }

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
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 20
            }

            WeatherWidget{
                id:weather_widget
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: gear_widget.right
                anchors.leftMargin: -20

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
                anchors.leftMargin: -20

                onClicked: stackView.push("qrc:/qml/pages/MapApplication.qml")
            }

            YoutubeWidget{
                id: youtube_widget
                iconSource: "qrc:/qml/images/icon_youtube.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: map_widget.right
                anchors.leftMargin: -20

                onClicked: stackView.push("qrc:/qml/pages/YoutubeApplication.qml")
            }

            MusicWidget{
                id: music_widget
                iconSource: "qrc:/qml/images/icon_music.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: youtube_widget.right
                anchors.leftMargin: -20

                onClicked: stackView.push("qrc:/qml/pages/MusicApplication.qml")
            }

            ModeWidget{
                id: mode_widget
                iconSource: "qrc:/qml/images/icon_mode.png"
                anchors.top: gear_widget.top
                anchors.topMargin: -10
                anchors.left: music_widget.right
                anchors.leftMargin: -20
            }

        }
    }
}
