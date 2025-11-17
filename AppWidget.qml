import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0


Item {
    id: root
    property int widthData: 200
    property int heightData: 120
    width: widthData
    height: heightData

    signal clicked()

    property alias contentItem: contentSlot.data

    Rectangle {
        id: widget_comp
        width: parent.width
        height: parent.height
        color: "transparent"
        radius: 5

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#314055"
            radius: 10
            samples: 16
            spread: 0.2
            x: 0
            y: 1
        }

        Item {
            id: contentSlot
            anchors.fill: parent
            anchors.margins: 10
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true

            // 하위/뒤쪽 MouseArea에도 이벤트가 전달되게 함
            propagateComposedEvents: true

            // 여기서 이벤트를 '소유'하지 않도록
            onPressed:  mouse.accepted = false
            onReleased: mouse.accepted = false

            onClicked: {
                // 카드 전체 클릭 시그널은 유지 (원하면 지워도 됨)
                root.clicked()
                // onClicked 에서는 mouse 파라미터가 없어서 여기선 accept 제어 불가
                // 위 onPressed/onReleased에서 false로 만들어 전파되게 한 거야
            }
        }

        transitions: Transition {
            NumberAnimation { properties: "scale"; duration: 120; easing.type: Easing.OutQuad }
        }
    }
}
