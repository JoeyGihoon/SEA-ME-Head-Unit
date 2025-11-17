// LightApplication.qml
import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: lightApplication
    width: 1024
    height: 600

    property var mainWindow
    // 뒤로가기 / 배경색 적용 시그널
    signal backRequested()
    signal applyColorRequested(color color)

    // 0.0 ~ 1.0 (hue)
    property real sliderValue: 0.0

    // 오버레이 투명도 (0 = 투명, 1 = 완전 불투명)
    property real overlayStrength: 0.2

    // 현재 색: HSV 색상환에서 hue만 슬라이더로 조절
    property color currentColor: Qt.hsva(sliderValue * 0.83, 1.0, 1.0, overlayStrength)

    function clamp01(x) {
        if (x < 0) return 0
        if (x > 1) return 1
        return x
    }

    Component.onCompleted: {
        if (mainWindow && mainWindow.backgroundSliderValue !== undefined) {
            sliderValue = mainWindow.backgroundSliderValue
        }
    }

    // ===== 상단 바 =====
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "#041c2e"
        anchors.top: parent.top

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "Light"
            color: "#dbe3ee"
            font.family: "Roboto"
            font.pixelSize: 32
        }

        Image {
            id: frontButton_grey
            width: 40; height: 40
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/qml/images/right_origin.png"
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
                opacity: mouseAreaBack.pressed ? 0.6 : (mouseAreaBack.containsMouse ? 0.85 : 1.0)
                scale: mouseAreaBack.pressed ? 0.92 : 1.0
                smooth: true
            }

            MouseArea {
                id: mouseAreaBack
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var view = lightApplication.parent
                    if (view && view.pop) {
                        view.pop()
                    } else {
                        lightApplication.backRequested()
                    }
                }
            }
        }
    }

    // ===== 메인 영역: 배경이미지 + 색 오버레이 + UI =====
    Item {
        id: mainArea
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        // 1) 원본 배경 이미지
        Image {
            id: baseBackground
            anchors.fill: parent
            source: "qrc:/qml/images/dark-blue-product-background.jpg" // 현재 쓰는 이미지
            fillMode: Image.PreserveAspectCrop
        }

        // 2) 이미지 위에 선택한 색을 입히는 오버레이
        ColorOverlay {
            id: tintedBackground
            anchors.fill: baseBackground
            source: baseBackground
            color: currentColor
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        // 3) 현재 색 텍스트
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            text: qsTr("Current Color: %1").arg(currentColor)
            color: "white"
            font.pixelSize: 20
            z: 1
        }

        // 4) 슬라이더
        Rectangle {
            id: sliderTrack
            z: 1
            width: parent.width * 0.7
            height: 14
            radius: 7
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            border.color: "#222222"
            border.width: 1

            // 핸들
            Rectangle {
                id: sliderHandle
                width: 60
                height: 60
                radius: 15
                color: "#ffffff"
                border.color: "#333333"
                anchors.verticalCenter: parent.verticalCenter

                x: sliderValue * (sliderTrack.width - width)

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "black"
                    opacity: 0.12
                    anchors.horizontalCenterOffset: 2
                    anchors.verticalCenterOffset: 2
                    z: -1
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: sliderHandle
                    drag.axis: Drag.XAxis
                    drag.minimumX: 0
                    drag.maximumX: sliderTrack.width - sliderHandle.width
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: {
                        var value = sliderHandle.x / (sliderTrack.width - sliderHandle.width)
                        sliderValue = clamp01(value)
                    }
                }
            }

            // 트랙 클릭으로도 위치 이동
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    var localX = mouse.x - sliderHandle.width / 2
                    var range = sliderTrack.width - sliderHandle.width
                    var value = localX / range
                    sliderValue = clamp01(value)
                }
            }
        }

        // 5) 우측 하단 Apply 버튼 (이 색을 전체 배경으로 적용)
        Item {
            id: applyButton
            z: 1
            width: 100
            height: 40
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 24
            anchors.bottomMargin: 24

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: "#041c2e"
                border.color: "#dbe3ee"
                opacity: mouseAreaApply.pressed ? 0.8 : 1.0

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        text: "Apply"
                        color: "#dbe3ee"
                        font.pixelSize: 16
                    }
                }
            }

            MouseArea {
                id: mouseAreaApply
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (mainWindow) {
                        mainWindow.backgroundTint = currentColor
                        mainWindow.backgroundSliderValue = sliderValue
                    }
                    // 부모(Main/HU)에서 받아서 실제 전체 배경을 이 색으로 바꾸면 됨
                    lightApplication.applyColorRequested(currentColor)
                }
            }
        }

        Item {
            id: resetButton
            z: 1
            width: 100
            height: 40
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24

            Rectangle {
                anchors.fill: parent
                radius: 20
                color: "#041c2e"
                border.color: "#dbe3ee"
                opacity: mouseAreaReset.pressed ? 0.8 : 1.0

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "Return"        // 또는 "Reset", "Default" 등
                        color: "#dbe3ee"
                        font.pixelSize: 16
                    }
                }
            }

            MouseArea {
                id: mouseAreaReset
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // 메인 배경 틴트 완전 제거
                    if (mainWindow) {
                        mainWindow.backgroundTint = Qt.rgba(0, 0, 0, 0)
                    }

                    // 필요하면 Light 화면 슬라이더도 초기 위치로 돌리고 싶다면:
                    // sliderValue = 0.0
                }
            }
        }
    }
}
