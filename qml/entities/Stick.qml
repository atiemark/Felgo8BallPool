import QtQuick
import Felgo

EntityBase {
    id: stick
    entityId: "playingStick"
    entityType: "stickType"
    visible: false

    transform: Rotation {
        id: stickRot
        angle: 0
    }


    property real stickDiameter
    property real ballDiameter

    property int stickImgWidthPx: 1902
    property int stickImgHeightPx: 53
    property real aimDistance: ballDiameter * 0.8
    property real shootingStrength: 6000
    property real chargingSpeed: 1.7
    property real maxCharge: 165

    property var rect: rect
    property point pointAtCenter
    property point chargeStartDistance
    property bool shooting: false

    property alias stickRotAngle: stickRot.angle

    Timer {
        id: stickPressedTimer
        interval: 1
        running: false // start running from the beginning, when the scene is loaded
        repeat: true // otherwise restart wont work
        property bool decrease: false

        onTriggered: {
            if(stickCharge.x > -maxCharge && !decrease)
                stickCharge.x -= chargingSpeed
            else if(stickCharge.x <= -maxCharge)
                decrease = true

            if(stickCharge.x < 0 && decrease)
                stickCharge.x += chargingSpeed
            else if(stickCharge.x >= 0)
                decrease = false
        }
    }

    Rectangle
    {
        id: parentRect
        height: stickDiameter * 10
        width: stick.stickImgWidthPx * (stickDiameter / stick.stickImgHeightPx) * 1.5
        color: "transparent"
        anchors.bottom: parent.top
        anchors.bottomMargin: -height/2 - stickDiameter/2


        MouseArea {
            anchors.fill: parent

            onPressed: {
                stickRot.origin.x = stick.rect.width + aimDistance
                stickRot.origin.y = stick.rect.height/2

                if(shooting)
                {
                    stick.enabled = false
                    stickPressedTimer.stop()
                    stickPressedTimer.decrease = false
                    shooting = false
                    stickShootAnimation.running = true
                    stick.parent.shoot(-stickCharge.x * shootingStrength, stickRot.angle)
                    stickResetAnimation.running = true
                    stickCharge.x = 0
                }
            }

            onPositionChanged: {
                var mouseAbs = mapToItem(stick.parent, mouseX, mouseY)
                var angle = - Math.atan2(mouseAbs.x - pointAtCenter.x, mouseAbs.y - pointAtCenter.y) * 180 / Math.PI - 90;
                stickRot.angle = angle
                stick.parent.updateAimHelper()
             }

            onDoubleClicked:
            {
                shooting = true
                stickPressedTimer.start()
            }
        }

        Rectangle {
               id: rect
               z: 100
               height: stickDiameter
               width: stick.stickImgWidthPx * (stickDiameter / stick.stickImgHeightPx)
               color: "transparent"
               anchors.verticalCenter: parentRect.verticalCenter

               transform: Translate {
                   id: stickCharge
                   x: 0
               }

               SequentialAnimation on x {
                           id: stickShootAnimation
                           // Animations on properties start running by default
                           running: false
                           NumberAnimation { from: 0; to: aimDistance; duration: 100; easing.type: Easing.Linear }
                       }

               SequentialAnimation on x {
                           id: stickResetAnimation
                           // Animations on properties start running by default
                           running: false
                           onFinished:
                           {
                               stick.visible = false
                           }

                           NumberAnimation { from: aimDistance; to: 0; duration: 100; easing.type: Easing.BezierSpline }
                       }

               Image {
                   id: image
                   source: Qt.resolvedUrl("../../assets/img/stick.png")
                   // set the size of the image to the one of the collider and not vice versa, because the physics properties depend on the collider size
                   anchors.fill: rect
               }
        }
    }


    function pointStickTo(whiteBall){
        var center = whiteBall.circleColliderBody.getWorldCenter()
        stick.pointAtCenter = center
        stick.x = center.x - stick.rect.width - aimDistance
        stick.y = center.y - stick.rect.height/2
        stick.visible = true
        stick.enabled = true
        stick.parent.updateAimHelper()
    }
}
