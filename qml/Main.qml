import Felgo 4.0 // for the gaming components
import QtQuick 2.0 // for the Image element
import QtQuick.Controls //for the Button
import "entities"

GameWindow {
    id: gameWindow
    activeScene: scene

    property var playerScore: [0, 0]

    EntityManager {
        id: entityManager
        entityContainer: scene
    }

    Scene {
        id: gameOverScene
        anchors.fill: parent
        enabled: false
        visible: false

        Rectangle{
            color: "transparent"
            anchors.fill: parent

            onVisibleChanged:
            {
                gameOverText.text = "Game Over! - Final Score:\nPlayer 1 (Solid Balls 1-7):\n" + gameWindow.playerScore[0] + "\n" +
                           "Player 2 (Striped Balls 9-15):\n" + gameWindow.playerScore[1]
            }

            Text {
                id: gameOverText
                font.pixelSize: scene.wallHeight
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                color: "white"
                z:1
            }

            MouseArea {
                anchors.fill: parent

                onReleased:
                {
                    scene.ballPositions = []
                    gameWindow.playerScore = [0, 0]
                    scene.curPlayer = 1
                    scene.whiteBall = null
                    scene.placeBalls()
                    gameOverScene.enabled = false
                    gameOverScene.visible = false
                    gameWindow.activeScene = scene
                    scene.enabled = true
                    scene.visible = true
                    initTimer.start()
                }
            }
        }
    }

    Scene {
        id: scene
        width: 1280

        //MAR: add the 8 ball playfield and ball dimensions in millimeters for later scaling
        property int fieldWidthMillimeter: 2240
        property int fieldHeightMillimeter: 1120
        property int pocketHoleDiameterMillimeter: 130
        property int wallHeightMillimeter: 60
        property int tableEdgeMillimeter: 60

        height: width * (fieldHeightMillimeter / fieldWidthMillimeter)

        property int ballDiameterMillimeter: 60
        property int ballWeightGrams: 160
        property int playBallTriangleNumRows: 5

        property real ballDiameter: width / (fieldWidthMillimeter / ballDiameterMillimeter)
        property real ballDensity: ballWeightGrams / (Math.pow(ballDiameter/2, 2) * Math.PI)    //density is in kg/pixel^2 - area of ball is (d/2)^2 * PI
        property real wallHeight:  width / (fieldWidthMillimeter / wallHeightMillimeter)
        property real pocketSizeDiameter: width / (fieldWidthMillimeter / pocketHoleDiameterMillimeter)
        property real tableEdge: width / (fieldWidthMillimeter / tableEdgeMillimeter)
        property var ballPositions: []

        property int curPlayer: 1

        property var whiteBall

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                    GradientStop { position: 0.0; color: "darkgreen" }
                    GradientStop { position: 1.0; color: "#008000" }
                }
            z: -1
        }

        Text {
            id: playerOneScoreText
            text: "    Player 1 (Solid Balls 1-7): " + gameWindow.playerScore[0]
            color: "white"
            font.pixelSize: scene.wallHeight * 0.7
            //anchors.left: parent.left
            anchors.left: topWallOne.left
            z: 200 // put on top of everything else in the Scene

            function updateScore()
            {
                gameWindow.playerScore[0]++
                playerOneScoreText.text = "    Player 1 (Solid Balls 1-7): " + gameWindow.playerScore[0]
            }
        }


        Text {
            id: playerTwoScoreText
            text: "Player 2 (Striped Balls 9-15): " + gameWindow.playerScore[1] + "    "
            color: "white"
            font.pixelSize: scene.wallHeight * 0.7
            anchors.right: topWallTwo.right
            x: -scene.pocketSizeDiameter
            z: 200 // put on top of everything else in the Scene

            function updateScore()
            {
                gameWindow.playerScore[1]++
                playerTwoScoreText.text = "Player 2 (Striped Balls 9-15): " + gameWindow.playerScore[1] + "    "
            }
        }

        Text {
            id: currentPlayerText
            text: "Current Player: " + scene.curPlayer
            color: "white"
            font.pixelSize: scene.wallHeight * 0.7
            anchors.horizontalCenter: parent.horizontalCenter
            y: scene.tableEdge/2
            z: 200 // put on top of everything else in the Scene

            function updatePlayer()
            {
                currentPlayerText.text = "Current Player: " + scene.curPlayer
            }
        }



        PhysicsWorld {
            id: physicsWorld
            gravity.y: 0.0 // make the objects fall faster
            debugDrawVisible: false

            // these are performance settings to avoid boxes colliding too far together
            // set them as low as possible so it still looks good
            updatesPerSecondForPhysics: 180
            velocityIterations: 90
            positionIterations: 90
            //pixelsPerMeter: 1280 / (scene.fieldWidthMillimeter/1000)
        }

        Wall {
            // bottom wall 1
            id: bottomWallOne
            height: scene.wallHeight
            width: (scene.width / 2) - scene.pocketSizeDiameter * 1.5 - scene.tableEdge
            x: scene.pocketSizeDiameter + scene.tableEdge
            y: scene.height - scene.wallHeight - scene.tableEdge

            //color: "brown"
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                        GradientStop { position: 0.0; color: "brown" }
                        GradientStop { position: 1.0; color: "#361B0C" }
                    }

            }


        }

        Wall {
            // bottom wall 2
            height: scene.wallHeight
            width: (scene.width / 2) - scene.pocketSizeDiameter * 1.6 - scene.tableEdge
            x: scene.pocketSizeDiameter * 2 + bottomWallOne.width + scene.tableEdge
            y: scene.height - scene.wallHeight - scene.tableEdge
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                        GradientStop { position: 0.0; color: "brown" }
                        GradientStop { position: 1.0; color: "#361B0C" }
                    }

            }
        }

        Wall {
            // left wall
            id: leftWall
            width: scene.wallHeight
            height: scene.height - scene.pocketSizeDiameter * 1.6 - scene.tableEdge * 2  - scene.wallHeight * 2
            y: scene.pocketSizeDiameter + scene.tableEdge + scene.wallHeight
            x: scene.wallHeight
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "brown";  }
                    GradientStop { position: 1.0; color: "#361B0C" }
                    }

            }
        }

        Wall {
            // right wall
            width: scene.wallHeight
            height: scene.height - scene.pocketSizeDiameter * 1.5 - scene.tableEdge * 2 - scene.wallHeight * 2
            y: scene.pocketSizeDiameter + scene.tableEdge + scene.wallHeight
            x: scene.width - scene.wallHeight - scene.tableEdge
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#361B0C" }
                    GradientStop { position: 1.0; color: "brown" }
                    }

            }
        }


        Wall {
            id: topWallOne
            height: scene.wallHeight
            width: (scene.width / 2) - scene.pocketSizeDiameter * 1.5 - scene.tableEdge
            x: scene.pocketSizeDiameter + scene.tableEdge
            y: scene.wallHeight + scene.tableEdge
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                        GradientStop { position: 0.0; color: "#361B0C" }
                        GradientStop { position: 1.0; color: "brown" }
                    }

            }
        }

        Wall {
            id: topWallTwo
            height: scene.wallHeight
            width: (scene.width / 2) - scene.pocketSizeDiameter * 1.5 - scene.tableEdge
            x: scene.pocketSizeDiameter * 2 + bottomWallOne.width + scene.tableEdge
            y: scene.wallHeight + scene.tableEdge
            Rectangle{
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#361B0C" }
                    GradientStop { position: 1.0; color: "brown" }
                    }

            }
        }


        Stick
        {
            id: playingStick
            z: 100
            ballDiameter: scene.ballDiameter
            stickDiameter: ballDiameter * 0.6
        }

        Component.onCompleted: {
            scene.placeBalls()
        }

         /*
        //show the ray that is being cast as a rectangle
        Rectangle {
            id: rayCastVisRect
            property real mx: 0
            property real my: 0

            property real len: 2 * Math.sqrt(mx * mx + my * my)

            rotation: 180 / Math.PI * Math.atan2(my, mx)

            transformOrigin: Item.Center

            x: scene.width / 2 - len / 2
            y: scene.height / 2
            width: len
            height: 2
            color: "red"
        }

        //highlight the object which is hit by the ray
        Rectangle {
            id: rect
            property Item target: null
            width: target ? target.width : 0
            height: target ? target.height : 0
            x: target ? target.x : 0
            y: target ? target.y : 0
            color: "green"
            opacity: 0.5
            rotation: target ? target.rotation : 0
            visible: !!target
            transformOrigin: Item.TopLeft
        }


        RayCast {
            id: raycast
            maxFraction: 2 //cast ray twice the distance from start to end point
            onFixtureReported: (fixture, contactPoint, contactNormal, fraction) =>
                               {
                                   //fixture.getBody() returns the body object, body.target returns the entity which contains the body
                                   var body = fixture.getBody()
                                   var entity = body.target

                                   rect.target = entity
                                   maxFraction = 0 // cancel current raycast, report no more objects
                               }
        }*/


        Timer {
            id: initTimer
            interval: 30
            running: false // start running from the beginning, when the scene is loaded
            repeat: true // otherwise restart wont work

            property int curBallNum: 0


            onTriggered: {

                var p = scene.ballPositions.pop()
                var newEntityPropertiesBall = {
                    x: p.x,
                    y: p.y,
                    z:1,
                    width: scene.ballDiameter,
                    height: scene.ballDiameter,
                    ballNumber: curBallNum,
                    density: scene.ballDensity
                }

                entityManager.createEntityFromUrlWithProperties(
                            Qt.resolvedUrl("entities/Ball.qml"),
                            newEntityPropertiesBall);


                // increase the curBallNum number
                curBallNum++

                if(scene.ballPositions.length == 0)
                {
                    initTimer.stop()
                    scene.whiteBall = entityManager.getEntityById("whiteBall")
                    playingStick.pointStickTo(scene.whiteBall)
                }
            }
        }

        Timer {
            id: endRoundTimer
            interval: 50
            running: false // start running from the beginning, when the scene is loaded
            repeat: true // otherwise restart wont work

            property var velocityQueue: []

            onTriggered: {
                var whiteBall = entityManager.getEntityById("whiteBall")
                var velX = whiteBall.velocity.x
                var velY = whiteBall.velocity.y

                velocityQueue.push(Math.abs(velX) + Math.abs(velY))
                if(velocityQueue.length > 3)
                    velocityQueue.shift()

                var balls = entityManager.getEntityArrayByType("ball")
                for (let i = 0; i < balls.length; i++)
                {
                    var ball = balls[i]
                    var ballNum = ball.ballNumber
                    if(scene.isBallinHole(ball))
                    {
                        //one of the playing balls went into a hole
                        if(ballNum !== 0 && ballNum !== 8){
                            if(ballNum < 8)
                                playerOneScoreText.updateScore()
                            else
                                playerTwoScoreText.updateScore()
                        }
                        else if(gameWindow.playerScore[scene.curPlayer-1] === 7 && ballNum === 8)
                        {
                            //black one needs to be put into hole last to win
                            gameWindow.playerScore[scene.curPlayer-1]++
                            scene.gameOver()
                        }
                        else
                        {
                            //check for game over if white or black ball is in hole too early
                            gameWindow.playerScore[scene.curPlayer-1] = -1
                            scene.gameOver()
                        }

                        ball.circleColliderBody.active = false
                        ball.enabled = false
                        entityManager.removeEntityById(ball.entityId)
                        balls.splice(i, 1)
                    }
                }

                if(gameWindow.playerScore[0] >= 8 || gameWindow.playerScore[1] >= 8)
                    scene.gameOver()

                //white ball doesnt move anymore, reset stick, end round and change player
                if(velocityQueue.reduce((a, b) => a + b, 0) === 0)
                {
                    playingStick.pointStickTo(whiteBall)
                    endRoundTimer.stop()

                    scene.curPlayer += 1
                    if(scene.curPlayer > 2)
                        scene.curPlayer = 1
                    currentPlayerText.updatePlayer()
                }
            }
        }

        function placeBalls()
        {
            var rowNum = scene.playBallTriangleNumRows
            var ballDiameter = scene.ballDiameter
            var triangleCenterX = scene.width * (2 / 3)
            var triangleCenterY = scene.height/2
            var triangleHeight = ((4 * ballDiameter) / 2) * Math.sqrt(3)
            var shortHeight = triangleHeight/3

            for (let x = rowNum; x > 0 ; x--) {
                //start with longest traingle row
                var curBallX = triangleCenterX + shortHeight - (triangleHeight/4) * (rowNum-x)

                var rowLength = (x - 1) * ballDiameter
                for (let y = x; y > 0 ; y--)
                {
                    var curBallY = triangleCenterY - rowLength/2 + (x-y)*ballDiameter
                    scene.ballPositions.push(Qt.point(curBallX, curBallY))
                }

            }

            function shuffleArray(array) {
                for (let i = array.length - 1; i >= 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [array[i], array[j]] = [array[j], array[i]];
                }
            }

            shuffleArray(scene.ballPositions)

            //add position for white ball
            scene.ballPositions.push(Qt.point(scene.width / 3, triangleCenterY))
        }

        function rotToVec(angle, amplitude)
        {
            return Qt.point(amplitude * Math.cos(angle* (Math.PI/180)), amplitude * Math.sin(angle * (Math.PI/180)))
        }

        function rayCast()
        {
            raycast.maxFraction = 2

                     //cast a ray from the mouse position through the center of the scene
            var center = scene.whiteBall.circleColliderBody.getWorldCenter()
            var from = Qt.point(center.x, center.y)
            rayCastVisRect.mx = from.x
            rayCastVisRect.my = from.y
            var rotVec = scene.rotToVec(playingStick.stickRotAngle, 10)
            var to = Qt.point(from.x + rotVec.x, from.y + rotVec.y)

            physicsWorld.rayCast(raycast, from, to)
        }

        function shoot(impulseStrength, angle){
            var ball = scene.whiteBall
            var center = ball.circleColliderBody.getWorldCenter()
            var vec = scene.rotToVec(angle, impulseStrength)
            ball.applyLinearImpulse(vec, center)
            endRoundTimer.start()
        }

        function isBallinHole(ball)
        {
            var center = ball.circleColliderBody.getWorldCenter()
            var holeDistance = scene.tableEdge + scene.wallHeight
            if(center.x < holeDistance || center.x > scene.width - holeDistance
                || center.y < holeDistance || center.y > scene.height - holeDistance)
            {
                return true
            }
            return false
        }

        function clearAllBalls(balls)
        {
            for (let u = 0; u < balls.length; u++)
            {
                balls[u].circleColliderBody.active = false
                balls[u].removeEntity()
                balls.splice(u, 1)
            }
            var toRemoveEntityTypes = ["ball"];
             entityManager.removeEntitiesByFilter(toRemoveEntityTypes);
        }


        function gameOver()
        {
            endRoundTimer.stop()
            initTimer.curBallNum = 0
            playingStick.stickRotAngle = 0
            scene.clearAllBalls(entityManager.getEntityArrayByType("ball"))
            gameWindow.activeScene = gameOverScene
            gameOverScene.enabled = true
            gameOverScene.visible = true
            scene.enabled = false
            scene.visible = false
        }
    }

    onSplashScreenFinished:
    {
        initTimer.start()
    }
}
