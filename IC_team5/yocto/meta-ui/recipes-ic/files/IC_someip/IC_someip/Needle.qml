import QtQuick 2.0

Item {
    id: needle_comp

    property int length: 120
    property int angle: 0

    width: 5
    height: length

    Rectangle{
        id: needle
        width: parent.width
        height: parent.height
        color: "red" //"#00b890";
        anchors.centerIn: parent
        transformOrigin: Item.Bottom
        rotation: angle

        Behavior on rotation {
            SmoothedAnimation {
                velocity: 900   // deg/sec target speed for smooth glide
                maximumEasingTime: 200
            }
        }

        gradient: Gradient{
            GradientStop { position: 0.0; color: "red" }
            GradientStop { position: 0.8; color: "black" }
        }
    }
}
