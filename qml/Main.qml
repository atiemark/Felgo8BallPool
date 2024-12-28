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
                gameOverText.text = "Game Over! - Final Score:\nScored Solid Balls (1-7):\n" + gameWindow.playerScore[0] + "\n" +
                        "Scored Striped Balls (9-15):\n" + gameWindow.playerScore[1]
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
        property var whiteBall

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#004000" }
                GradientStop { position: 1.0; color: "green" }
            }
            z: -1
        }

        Text {
            id: playerOneScoreText
            color: "white"
            font.pixelSize: scene.wallHeight * 0.7
            //anchors.left: parent.left
            anchors.left: topWallOne.left
            z: 200 // put on top of everything else in the Scene

            function updateScore(add)
            {
                gameWindow.playerScore[0] += add
                playerOneScoreText.text = "    Scored Solid Balls (1-7): " + gameWindow.playerScore[0]
            }
        }


        Text {
            id: playerTwoScoreText
            color: "white"
            font.pixelSize: scene.wallHeight * 0.7
            anchors.right: topWallTwo.right
            x: -scene.pocketSizeDiameter
            z: 200 // put on top of everything else in the Scene

            function updateScore(add)
            {
                gameWindow.playerScore[1] += add
                playerTwoScoreText.text = "Scored Striped Balls (9-15): " + gameWindow.playerScore[1] + "    "
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
                gradient: Gradient
                {
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
            Rectangle
            {
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient
                {
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
            Rectangle
            {
                anchors.fill: parent
                radius: scene.pocketSizeDiameter/2
                gradient: Gradient
                {
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


        //show the ray that is being cast as a rectangle
        Rectangle {
            id: rayCastVisRect
            transformOrigin: Item.Left
            visible: false
            antialiasing: true

            property point from
            property point to

            onToChanged: {
                width = Math.abs(Math.hypot(from.x - to.x, from.y - to.y))
            }

            width: scene.width
            height: 1
            color: "white"
        }


        RayCast {
            id: raycast
            maxFraction: scene.width
            onFixtureReported: (fixture, contactPoint, contactNormal, fraction) =>
                               {
                                   maxFraction = fraction // cancel current raycast, report no more objects
                                   rayCastVisRect.to = contactPoint
                               }
        }


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
                    scene.updateAimHelper()
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
                scene.updateAfterShoot()
            }
        }


        Component.onCompleted: {
            scene.placeBalls()
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

            //init score
            gameWindow.playerScore = [0, 0]
            playerOneScoreText.updateScore(0)
            playerTwoScoreText.updateScore(0)
        }


        function updateAfterShoot()
        {
            var whiteBall = entityManager.getEntityById("whiteBall")
            var velX = whiteBall.velocity.x
            var velY = whiteBall.velocity.y

            var velQueue = endRoundTimer.velocityQueue
            velQueue.push(Math.abs(velX) + Math.abs(velY))
            if(velQueue.length > 3)
                velQueue.shift()

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
                        {
                            playerOneScoreText.updateScore(1)
                        }
                        else
                        {
                            playerTwoScoreText.updateScore(1)
                        }
                    }
                    else //white or black ball went into a hole
                    {
                        scene.gameOver()
                    }

                    ball.circleColliderBody.active = false
                    ball.enabled = false
                    entityManager.removeEntityById(ball.entityId)
                    balls.splice(i, 1)
                }
            }

            //white ball doesnt move anymore - reset stick, end round and change player
            if(velQueue.reduce((a, b) => a + b, 0) === 0)
            {
                playingStick.pointStickTo(whiteBall)
                endRoundTimer.stop()
            }
        }


        function rotToVec(angle, amplitude)
        {
            return Qt.point(amplitude * Math.cos(angle* (Math.PI/180)), amplitude * Math.sin(angle * (Math.PI/180)))
        }

        function updateAimHelper()
        {
            console.log("update aim")
            var center = scene.whiteBall.circleColliderBody.getWorldCenter()
            var from = Qt.point(center.x, center.y)
            var rotVec = scene.rotToVec(playingStick.stickRotAngle, 1)
            var to = Qt.point(from.x + rotVec.x, from.y + rotVec.y)

            rayCastVisRect.from = from
            rayCastVisRect.x = from.x
            rayCastVisRect.y = from.y
            rayCastVisRect.rotation = playingStick.stickRotAngle

            raycast.maxFraction = scene.width
            physicsWorld.rayCast(raycast, from, to)
            physicsWorld.rayCast(raycast, from, to)

            rayCastVisRect.visible = true
        }

        function shoot(impulseStrength, angle){
            var ball = scene.whiteBall
            var center = ball.circleColliderBody.getWorldCenter()
            var vec = scene.rotToVec(angle, impulseStrength)
            ball.applyLinearImpulse(vec, center)
            endRoundTimer.start()
            rayCastVisRect.visible = false
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
