import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    anchors.fill: parent

    // ===== background =====
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/qml/images/dark-blue-product-background.jpg"   // 배경으로 쓰려는 이미지 경로
        fillMode: Image.PreserveAspectCrop // 화면 꽉 차게, 비율 유지
        asynchronous: true                 // 로딩 비동기
        cache: true
        z: 0                              // 혹시 모를 순서 문제 대비 (선언을 맨 위에 두면 굳이 없어도 됨)
    }

    // === 좌측 세로 기어 인디케이터 ===
    Rectangle {
        id: gearPanel
        width: 74
        height: 300
        radius: 12
        color: "transparent"
        border.color: "#314055"
        border.width: 2

        // 원하는 위치에 앵커만 바꿔 쓰세요
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter

        // 외부에서 바꾸면 UI가 반영됩니다: gearPanel.currentGear = "D"
        property int panelPadding: 8
        property int itemSpacing: 4
        property var gears: ["P","R","N","D"]
        property string currentGear: "P"

        // 색상 커스터마이즈
        property color activeColor:  "#35c2b1"
        property color inactiveColor:"#a9b4c7"
        property color activeBg:     "#1f2a33"   // 활성 라인 뒤 배경 (살짝 진하게)
        property int   cellH:        Math.floor((height - panelPadding*2 - itemSpacing*(gears.length-1)) / gears.length)

        Column {
            id: col
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: gearPanel.gears
                delegate: Item {
                    width: col.width
                    height: gearPanel.cellH
                    property bool active: gearPanel.currentGear === modelData

                    // 활성 줄 배경 하이라이트
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: active ? gearPanel.activeBg : "transparent"
                        Behavior on color { ColorAnimation { duration: 160 } }
                    }

                    // 기어 문자
                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 28
                        font.weight: active ? Font.DemiBold : Font.Normal
                        color: active ? gearPanel.activeColor : gearPanel.inactiveColor
                        opacity: active ? 1.0 : 0.8
                        scale: active ? 1.08 : 1.0

                        Behavior on color   { ColorAnimation { duration: 140 } }
                        Behavior on opacity { NumberAnimation { duration: 140 } }
                        Behavior on scale   { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }
                    }

                    // 빛나는 효과(바깥 글로우)
                    DropShadow {
                        anchors.fill: label
                        source: label
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: active ? 16 : 0     // 0이면 효과 꺼짐
                        samples: 25
                        color: gearPanel.activeColor
                        transparentBorder: true
                        opacity: active ? 0.9 : 0.0
                        visible: active || opacity > 0
                        Behavior on radius { NumberAnimation { duration: 160 } }
                        Behavior on opacity { NumberAnimation { duration: 160 } }
                    }

                    // (선택) 마우스로도 기어 변경하고 싶으면 클릭 가능
                    MouseArea {
                        anchors.fill: parent
                        onClicked: gearPanel.currentGear = modelData
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    Image {
        id: car
        width: 700
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: -100
        anchors.topMargin: 50
        source: "qrc:qml/images/car.png"
        fillMode: Image.PreserveAspectFit
        smooth: true

    }

    // ===== 하단 원형 버튼 5개 =====
    Row {
        id: actions
        spacing: 80
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50

        Component {
            id: imageButton
            Item {
                id: btn
                property alias text: label.text
                property url iconSource: ""
                property int iconSize: 80      // 아이콘 크기만 바꿔도 전체 버튼 크기 조정
                signal clicked()

                width: iconSize; height: iconSize + 32  // 라벨 공간 조금 포함

                Column {
                    anchors.fill: parent
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    // 이미지 자체가 버튼 비주얼
                    Image {
                        id: icon
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: btn.iconSource
                        width: btn.iconSize
                        height: btn.iconSize
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: true
                        smooth: true

                        // 스케일 시 선명도 유지(약간 크게 로드)
                        sourceSize.width: btn.iconSize * 2
                        sourceSize.height: btn.iconSize * 2
                    }

                    // (선택) 라벨
                    Text {
                        id: label
                        text: "Label"
                        color: "#d3dae6"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: text.length > 0
                    }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: btn.clicked()
                }

                // 호버/프레스 효과 그대로 유지
                states: [
                    State { name: "hover"; when: btnMouse.containsMouse
                        PropertyChanges { target: btn; scale: 1.04 } },
                    State { name: "press"; when: btnMouse.pressed
                        PropertyChanges { target: btn; scale: 0.97 } }
                ]
                transitions: [
                    Transition { NumberAnimation { properties: "scale"; duration: 120; easing.type: Easing.OutQuad } }
                ]
            }
        }

        // 5개 버튼 인스턴스
        Loader {
            sourceComponent: imageButton
            onLoaded: {
                item.text = "Map"
                item.iconSource = "qrc:/qml/images/icon_maps.png"
                item.clicked.connect(()=> console.log("Map clicked"))
            }
        }
        Loader {
            sourceComponent: imageButton
            onLoaded: {
                item.text = "Weather"
                item.iconSource = "qrc:/qml/images/icon_weather.png"
                item.clicked.connect(()=> console.log("Weather clicked"))
            }
        }
        Loader {
            sourceComponent: imageButton
            onLoaded: {
                item.text = "Music"
                item.iconSource = "qrc:/qml/images/icon_music.png"   // PNG/JPG 사용
                item.clicked.connect(()=> console.log("Gear clicked"))
            }
        }
        Loader {
            sourceComponent: imageButton
            onLoaded: {
                item.text = "YouTube"
                item.iconSource = "qrc:/qml/images/icon_youtube.png"
                item.clicked.connect(()=> console.log("YouTube clicked"))
            }
        }
        Loader {
            sourceComponent: imageButton
            onLoaded: {
                item.text = "Settings"
                item.iconSource = "qrc:/qml/images/icon_mode.png"    // JPG도 OK
                item.clicked.connect(()=> console.log("Settings clicked"))
            }
        }
    }

    MapWidget {
        id: map_widget
        anchors.left: gearPanel.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            anchors.fill: parent
            onClicked: {
                stackView.push("qrc:/MapApplication.qml")
            }
        }
    }

    Text {
        id: topRightClock
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        text: Qt.formatDateTime(new Date(), "MMM.d  hh:mm")    // 24h면 "HH:mm"
        color: "#dbe3ee"
        font.family: "Roboto"       // 예: Roboto, Noto Sans, Open Sans 등
        //font.weight: Font.Light     // 또는 Font.Thin
        font.pixelSize: 28

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: topRightClock.text = Qt.formatDateTime(new Date(), "MMM.d  hh:mm")
        }
    }

    Image {
        id: topLeftLogo
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        anchors.topMargin: -10
        source: "qrc:qml/images/seame.png"
        width: 88; height: 88
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Image {
        id: topcenterLogo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        // anchors.topMargin: 0
        source: "qrc:qml/images/m5logo.png"
        width: 100; height: 80
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
