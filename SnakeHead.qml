import QtQuick 2.12

Rectangle {
    width: 20
    height:20
    //rotation: 45
    radius: 10
//    color: Qt.rgba(1, 0, 0, 0.8)
    gradient: Gradient{
        GradientStop { position: 0.0; color: Qt.rgba(1, 0, 0, 0.8) }
        GradientStop { position: 1.0; color: Qt.rgba(0.5, 0.2, 0.8, 0.8) }
    }
}
