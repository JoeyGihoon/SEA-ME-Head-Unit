import QtQuick 2.0
import QtGraphicalEffects 1.0
Item {
    id: weatherWidget
    width: 220
    height: 560

    signal clicked()
    property string city: "Wolfsburg"
    // 외곽 박스/그림자 카드
    AppWidget {
        id: card
        widthData: parent.width
        heightData: parent.height

        contentItem: Rectangle {
            id: frame
            property string city: "Wolfsburg"
            anchors.fill: parent
            anchors.margins: 10               // 카드 안쪽 여백
            radius: 12
            color: "transparent"
            border.color: "#314055"
            border.width: 2

            Text{
                id: weatherTitle
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10
                text: "Weather"
                font.pixelSize: 24
                color: "#d95353"
            }

            Rectangle {
                id: underlineBar
                anchors.top: weatherTitle.bottom
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
                id: layout
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                // anchors.horizontalCenterOffset: 8
                anchors.verticalCenter: parent.verticalCenter
                // anchors.fill: parent
                // anchors.margins: 20
                spacing: 20

                // 지역
                Text {
                    id: region
                    text: ""
                    // text: "Wolfsburg"
                    font.pixelSize: 28
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width   // 중앙정렬 기준 폭
                }

                // 날씨 아이콘
                Image {
                    id: weatherImage
                    width: 100
                    height: 100
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: false
                }

                // 온도
                Text {
                    id: tempInfo
                    font.pixelSize: 32
                    color: "white"
                    text: ""                     // 수신 전엔 비워둠
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // 처음 로드 시 한 번 조회
            Component.onCompleted: {
                weather.fetchWeatherData(weatherWidget.city)
            }

            // 주기 갱신 (운영 시 60초 이상 권장)
            Timer {
                id: updateTimer
                interval: 60000                  // 60초
                running: true
                repeat: true
                onTriggered: weather.fetchWeatherData(region.text)
            }

            // C++ Weather 객체 시그널 수신
            Connections {
                target: weather
                function onWeatherDataReceived(cityName, temperature, weatherDescription, iconPath) {
                    region.text = cityName;   // API가 보내는 도시명을 그대로 쓸 거면 주석 해제
                    weatherImage.source = iconPath
                    weatherImage.visible = !!iconPath
                    tempInfo.text = Number(temperature).toFixed(1) + "  °C"
                }
                function onErrorOccurred(err) {
                    console.error("Weather error:", err)
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: weatherWidget.clicked()
            }
        }
    }
}
