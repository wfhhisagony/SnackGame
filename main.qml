import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.14

Window {    // 整个游戏窗口，可以看作一个矩形窗口
    id: myWindow
    minimumWidth: gameScene.width+10
    maximumWidth: gameScene.width+10
    minimumHeight: gameScene.height+10
    maximumHeight: gameScene.height+10
    visible: true
    color:  Qt.rgba(0,0.8,0.4,1)

    Rectangle{
        id: gameScene
        anchors.centerIn: parent
        width: 400
        height: 400
        border.color: Qt.rgba(1,1,1,1)
       // border.width: 4
        color: "lightgrey"
        focus: true

        property var snakePositions: [] // 贪吃蛇身体及头的坐标
        property var snakeBody: []  // 存放可视化的组件
        property var foodPos: QtObject{ // 食物位置
            property int x; property int y;
        }

        property var direction: QtObject{   // 蛇头移动的方向
            property int x: snakeHead.width;
            property int y: 0;
        }

        Loader{
            id: snakeHead
            source: "SnakeHead.qml"
        }


        Loader{
            id: food
            source: "Food.qml"
        }


        Timer { // 计时器，来控制贪吃蛇自己会不断移动
            id: timer
            interval: 100
            running: false
            repeat: true
            property alias snakePositions: gameScene.snakePositions
            property alias foodPos: gameScene.foodPos
            property alias direction: gameScene.direction

            onTriggered: {  // 计时器到时，触发以下事件  画出蛇头、蛇身以及食物
                var headPos = Qt.point(snakePositions[0].x, snakePositions[0].y) // 注意是方块左上角的坐标  深拷贝
                var nextHeadPos = getNextHeadPos(headPos);
                var lastBodyPos = Qt.point(snakePositions[snakePositions.length - 1].x, snakePositions[snakePositions.length - 1].y);   // 深拷贝
                if(isCollided(nextHeadPos.x, nextHeadPos.y)) return;
                changeHeadPos(nextHeadPos.x, nextHeadPos.y);
                changeBodyPos(headPos)
                tryEatFood(nextHeadPos, lastBodyPos);
                gameScene.moveHead()
                gameScene.moveBody()
            }

            function getNextHeadPos(headPos){
                var x = headPos.x + direction.x
                var y = headPos.y + direction.y
                return Qt.point(x, y);
            }

            function changeHeadPos(x, y){
                snakePositions[0].x = x;
                snakePositions[0].y = y; // 替换值
            }

            function changeBodyPos(headPos){
                var i;
                for(i=snakePositions.length-1;i>1;i--){
                    snakePositions[i] = snakePositions[i-1];
                }
                if(snakePositions.length>=2){
                    snakePositions[1] = headPos;
                }
            }

            function isCollided(x, y){  // next headpos  碰撞检测
                // 头出界 游戏结束
                if (x < 0 || x >= gameScene.width || y < 0 || y >= gameScene.height) {
                    gameScene.gameOver();
                    return true;
                }
                // 咬到自己的身体，游戏结束
                for (var i = 1; i < snakePositions.length; i++) {
                    if (x === snakePositions[i].x && y === snakePositions[i].y) {
                        gameScene.gameOver();
                        return true;
                    }
                }
                return false;
            }

            function tryEatFood(nextHeadPos, lastBodyPos){
                if (nextHeadPos.x === foodPos.x && nextHeadPos.y === foodPos.y) {
                    gameScene.randomFoodPos()    // 重新放置食物的位置
                    gameScene.moveFood()
                    gameScene.addBody(lastBodyPos.x, lastBodyPos.y);
                }
            }
        }




        Keys.onPressed: handleKeyDown(event)    // 使用自己编写的函数

        function setDirection(x, y){
            direction.x = x;
            direction.y = y;
        }

        function handleKeyDown(event) {
            switch (event.key) {
            case Qt.Key_A:
                setDirection(-snakeHead.width,  0);
                snakeHead.rotation += 180   // 随便添加一下旋转效果
                break
            case Qt.Key_D:
                setDirection(snakeHead.width,  0);
                snakeHead.rotation += 180
                break
            case Qt.Key_W:
                setDirection(0,  -snakeHead.width);
                snakeHead.rotation += 90
                break
            case Qt.Key_S:
                setDirection(0, snakeHead.width);
                snakeHead.rotation -= 90
                break
            }
            event.accepted = false;
        }

        function randomFoodPos() {
            var tmp1 = Math.floor( (Math.random() * gameScene.width) / food.width)
            var tmp2 = Math.floor( (Math.random() * gameScene.height) / food.height)
            var x = tmp1 * food.width
            var y = tmp2 * food.height
            foodPos.x = x;
            foodPos.y = y;
        }

        function randomHeadPos(){   // 不在边界出生
            snakePositions.length = 0;  // clear
            var tmp1 = Math.floor( (Math.random() * (gameScene.width-3*snakeHead.width) ) / snakeHead.width) +3
            var tmp2 = Math.floor( (Math.random() * (gameScene.height-3*snakeHead.height )) / snakeHead.height) +3
            var x = tmp1 * snakeHead.width
            var y = tmp2 * snakeHead.height
            snakePositions.push(Qt.point(x, y))
            console.debug(snakePositions)
        }

        function moveFood(){
            food.x = foodPos.x;
            food.y = foodPos.y;
        }

        function moveHead(){
            snakeHead.x = snakePositions[0].x
            snakeHead.y = snakePositions[0].y
        }

        function moveBody(){
            for(var i=1; i<snakePositions.length;i++){
                snakeBody[i-1].x = snakePositions[i].x;
                snakeBody[i-1].y = snakePositions[i].y;
            }
        }



        function addBody(x, y){ // 走了才addBody
            var component = Qt.createComponent("SnakeBody.qml");    // create visible component
            if (component.status === Component.Ready) {
                var newBodyPart = component.createObject(gameScene); // set parent and the value of x,y is decided by parent
                newBodyPart.x = x;
                newBodyPart.y = y;
                snakeBody.push(newBodyPart);
                snakePositions.push(Qt.point(x,y));
            }
        }

        Rectangle {     // 游戏结束的对话框(矩形)
            id: messageDialog
            width: 300
            height: 200
            color: "white"
            border.color: "black"
            radius: 10
            visible: false
            anchors.centerIn: parent
            property alias text: rectText.text

            Text {
                id: rectText
                textFormat: Text.RichText
                text: "<h1>Game Over</h1>"
                font.pixelSize: 20
                anchors.centerIn: parent
            }
        }

        function gameOver() {
            timer.stop()
            messageDialog.text = "<h2>Game Over</h2><br>press space to restart"
            messageDialog.visible = true
        }

        function gameStart(){
            messageDialog.visible = false;
            snakePositions.length = 0;
            for(var i=0;i<snakeBody.length; i++){
                snakeBody[i].destroy();
            }
            snakeBody.length = 0;
            randomFoodPos();
            randomHeadPos();
            moveHead();
            moveFood();
            setDirection(snakeHead.width, 0);
            timer.start();
        }

        Component.onCompleted: {    // 一开始设置食物和蛇头随机坐标
            gameStart();
        }

        Keys.onSpacePressed: {    // 若失败，空格键重新开始
            gameStart();
        }
    }




}
