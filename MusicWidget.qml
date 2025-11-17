// MapWidget.qml
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: musicWidget
    width: 220
    height: 560

    // 외부에서 쓰는 API
    signal clicked()
    property url iconSource: "qrc:/qml/images/icon_music.qml"   // 필요시 Main.qml에서 바꿔 넣어줘
    property int iconSize: 80
    property string title: "Music"

    // 날씨 위젯이 쓰는 것과 같은 카드 컨테이너
    AppWidget {
        id: card
        widthData: parent.width
        heightData: parent.height

        // 파란 테두리 박스 (글로우 효과는 AppWidget의 DropShadow)
        contentItem: Rectangle {
            id: panel
            anchors.fill: parent
            anchors.margins: 10
            radius: 12
            color: "transparent"
            border.color: "#314055"     // 날씨 위젯과 동일한 파란 라인
            border.width: 2

            Text{
                id: musicTitle
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10
                text: "Music"
                font.pixelSize: 24
                color: "#d95353"
            }

            Rectangle {
                id: underlineBar
                anchors.top: musicTitle.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: 170
                height: 3
                radius: 2

                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, 0)
                    end: Qt.point(parent.width, 0)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "white" }
                        GradientStop { position: 1.0; color: "red" }
                    }
                }
            }

            Column {
                id: iconBlock
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Image {
                    id: icon
                    source: musicWidget.iconSource
                    sourceSize.width: musicWidget.iconSize
                    sourceSize.height: musicWidget.iconSize
                    width: musicWidget.iconSize
                    height: musicWidget.iconSize
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    visible: source !== ""
                }
            }

            // 테두리 내부 전체 클릭 → 외부로 clicked() 신호
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: musicWidget.clicked()
            }
        }
    }
}

