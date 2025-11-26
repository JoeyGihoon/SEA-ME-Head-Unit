import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: weatherApplication

    property string currentCity: ""
    property real   currentTemp: NaN
    property string currentDesc: ""
    property url    currentIcon: ""

    property string searchText: ""
    property var forecastData: []
    signal backRequested()

    // ===== 상단 바 (뒤로가기 버튼 자리) =====
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "#041c2e"         // 상단 바 배경색 (필요 시 조정)
        anchors.top: parent.top

        Text{
            id: weatherpage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "Weather"
            color: "#dbe3ee"
            font.family: "Roboto"       // 예: Roboto, Noto Sans, Open Sans 등
            //font.weight: Font.Light     // 또는 Font.Thin
            font.pixelSize: 32
        }

        Image {
            id: frontButton_grey
            width: 40; height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:qml/images/right_origin.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Item {
            id: backButton
            width: 40; height: 40
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: backIcon
                anchors.centerIn: parent
                source: "qrc:/qml/images/left_green.png"
                width: 40; height: 40
                fillMode: Image.PreserveAspectFit
                opacity: mouseArea.pressed ? 0.6 : (mouseArea.containsMouse ? 0.85 : 1.0)
                scale: mouseArea.pressed ? 0.92 : 1.0
                smooth: true
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    var view = weatherApplication.parent
                    if (view && view.pop) {
                        view.pop()
                    } else {
                        weatherApplication.backRequested()
                    }

                    // weather.fetchWeatherData(searchField.text)
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    Connections {
        target: weather
        onWeatherDataReceived: function(city, temp, desc, iconPath) {
            currentCity = city
            currentTemp = temp
            currentDesc = desc
            currentIcon = iconPath
        }
        onForecastDataReceived: function(city, list) {
            forecastData = list
        }
        onErrorOccurred: function(msg) {
            console.log("Weather error:", msg)
        }
    }

    Row {
        id: searchBox
        anchors.top: topBar.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 10

        TextField {
            id: searchField
            placeholderText: "Enter the city..."
            width: 500

            onTextChanged: searchText = text
        }

        Button {
            text: "Search"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentIcon = ""
                    currentTemp = NaN
                    weather.fetch5daysWeather(searchField.text)
                    weather.fetchWeatherData(searchField.text)
                }
            }
        }
    }

    Row{
        id: todayInfo
        visible: currentIcon !== "" && isFinite(currentTemp)
        anchors.top: searchBox.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        Column{
            spacing: 10
            Text{
                text: "Today"
                font.pixelSize: 50
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Image{
                source: currentIcon
                width: 100
                height: 100
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: isFinite(currentTemp) ? Number(currentTemp).toFixed(1) + " °C" : ""
                font.pixelSize: 50
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Row {
        id: forecastInfo
        anchors.top: searchBox.bottom
        anchors.topMargin: 280
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 30

        Repeater {
            model: forecastData
            onModelChanged: console.log("Forecast data:", forecastData)

            Column {
                spacing: 10

                Text {
                    text: modelData.dateTime || "No dateTime" // 날짜
                    font.pixelSize: 20
                    color: "white"

                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Image {
                    source: modelData.iconPath || "" // 아이콘 경로
                    width: 50
                    height: 50
                    fillMode: Image.PreserveAspectFit

                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: modelData.temperature + " °C" || "No temp" // 온도
                    font.pixelSize: 20
                    color: "white"

                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Text {
                //     text: modelData.description || "No description" // 날씨 설명
                //     font.pixelSize: 20
                //     color: "white"

                //     anchors.horizontalCenter: parent.horizontalCenter
                // }
            }
        }

        Connections {
                target: weather
                function onForecastDataReceived(cityName, receivedData) {
                    console.log("Forecast data received:", receivedData)
                    receivedData.forEach(function(item, index) {
                                console.log("Item " + index + ":", item);
                                console.log("DateTime:", item.dateTime);
                                console.log("Temperature:", item.temperature);
                                console.log("Description:", item.description);
                                console.log("IconPath:", item.iconPath);
                            });
                    forecastData = receivedData
                }
            }
    }

}

