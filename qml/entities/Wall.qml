//![0]
import QtQuick 2.0
import Felgo 4.0
// for accessing the Body.Static type

EntityBase {
    entityType: "wall"

    // this gets used by the top wall to detect when the game is over
    signal collidedWithBox

    // this allows setting the color property or the Rectangle from outside, to use another color for the top wall
    property alias color: rectangle.color

    property alias collider: collider

    BoxCollider {
        id: collider
        anchors.fill: parent
        bodyType: Body.Static // the body shouldnt move
        friction: 0
        restitution: 1

        fixture.onBeginContact: collidedWithBox()
    }
}
//![0]
