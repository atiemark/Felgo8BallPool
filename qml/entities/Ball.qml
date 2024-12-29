import QtQuick
import QtQuick.Shapes 1.11
import Felgo

EntityBase {
  id: ballEntity
  entityType: "ball"

  property int ballNumber : 0
  property real density
  property var colors: ["yellow", "blue", "red", "purple", "orange", "green", "maroon", "black"]

  property alias velocity: circleCollider.linearVelocity
  property alias centerX: circleCollider.anchors.horizontalCenter
  property alias centerY: circleCollider.anchors.verticalCenter

  entityId: ballNumber == 0 ? "whiteBall" : "playBall" + ballNumber

  property alias circleColliderBody: circleCollider.body


  Rectangle {
      id: circle
      width: ballEntity.width; height: width
      radius: width / 2
      color: ballEntity.ballNumber == 0 ? "white" : qsTr(ballEntity.colors[(ballEntity.ballNumber-1) % ballEntity.colors.length]);
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter


      Shape {
          rotation: 45 + 90
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          visible: (ballEntity.ballNumber > colors.length) ? true : false
          ShapePath {
              fillColor: "white"
              strokeColor: "transparent"
              startX: circle.radius; startY: 0

              PathArc {
                    x: 0; y: circle.radius
                    radiusX: circle.radius; radiusY: circle.radius
                    useLargeArc: false
                }
          }
      }

      Shape {
          rotation: 45 + 90 + 180
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          visible: (ballEntity.ballNumber > colors.length) ? true : false
          ShapePath {
              fillColor: "white"
              strokeColor: "transparent"
              startX: circle.radius; startY: 0

              PathArc {
                    x: 0; y: circle.radius
                    radiusX: circle.radius; radiusY: circle.radius
                    useLargeArc: false
                }
          }
      }
  }

  Rectangle {
      id: innerCircle
      width: ballEntity.width/2.1; height: width
      radius: width / 2
      color: "white"
      visible: ballEntity.ballNumber == 0 ? false : true
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
  }


  Text {
      id: number
      text: qsTr(ballEntity.ballNumber.toString())
      font.pointSize: ballEntity.width/4
      visible: ballEntity.ballNumber == 0 ? false : true
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter

  }


  CircleCollider {
      id: circleCollider
      // approximate the collider with the image size - if the image is circular, this is a good approximation
      radius: circle.width/2
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter

      friction: 0
      restitution: 1 // restitution is bounciness
      density: ballEntity.density*2 // this makes the ball more heavy
      angularDamping: 1.5
      linearDamping: 1.5

      fixture.onBeginContact: (other, contactNormal) => {
                                  // when colliding with another entity, play the sound and start particleEffect
                                  //collisionSound.play();
                                  //collisionParticleEffect.start();
                              }
  }


    function applyLinearImpulse(impulseVector, worldPoint)
    {
      circleCollider.applyLinearImpulse(impulseVector, worldPoint)
    }
}
