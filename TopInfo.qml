// TopInfo.qml
import QtQuick 2.12
import QtGraphicalEffects 1.0

AppWidget {
    id: root
    widthData: 900
    heightData: 88

    contentItem: Item {
        anchors.fill: parent

        // 좌측 로고
        Image {
            id: topLeftLogo
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 10
            anchors.topMargin: -20
            source: "qrc:/qml/images/seame.png"
            width: 88; height: 88
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        // 중앙 로고
        Image {
            id: topCenterLogo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -15
            source: "qrc:/qml/images/m5logo.png"
            width: 100; height: 80
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        // 우측 시계
        Text {
            id: topRightClock
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5
            text: Qt.formatDateTime(new Date(), "MMM.d  hh:mm")
            color: "#dbe3ee"
            font.family: "Roboto"
            font.pixelSize: 21

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: topRightClock.text = Qt.formatDateTime(new Date(), "MMM.d  hh:mm")
            }
        }
    }
}
