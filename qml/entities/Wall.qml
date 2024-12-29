import QtQuick 2.0
import Felgo 4.0
// for accessing the Body.Static type

EntityBase {
    entityType: "wall"

    property alias collider: collider

    BoxCollider {
        id: collider
        anchors.fill: parent
        bodyType: Body.Static // the body shouldnt move
        friction: 0
        restitution: 1
    }
}

