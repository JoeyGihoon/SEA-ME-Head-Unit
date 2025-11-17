import QtQuick 2.0
import QtWebEngine 1.7

Item {
    id: mapApplication
    width: 1024
    height: 600

    signal backRequested()

    // ===== 상단 바 (뒤로가기 버튼 자리) =====
    Rectangle {
        id: topBar
        width: parent.width
        height: 60
        color: "#041c2e"         // 상단 바 배경색 (필요 시 조정)
        anchors.top: parent.top

        Text{
            id: mappage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: "Map"
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
                    if (mapObject.canGoBack) {
                        mapObject.goBack()
                    } else {
                        // 🔹 parent가 StackView이면 자동 pop
                        var view = mapApplication.parent
                        if (view && view.pop) {
                            view.pop()
                        } else {
                            mapApplication.backRequested()
                        }
                    }
                }
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    WebEngineView {
        id: mapObject
        width: 1024
        height: 600
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topBar.bottom
        //anchors.topMargin: 40

        onLoadingChanged: {
                    if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                        console.error("Failed to load Google Map:", loadRequest.errorString)
                    }
                }

        Component.onCompleted: {
            if (mapController === null) {
                console.error("mapController is null");
            } else {
                console.log("mapController is available");
                mapObject.loadHtml(mapController.getGoogleMapHtml_app());
            }
        }
    }
}
