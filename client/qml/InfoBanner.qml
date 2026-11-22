import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 业务结果提示条：绑定 message / error；用户可点 × 关闭（closed 信号）。
Rectangle {
    id: banner

    property string message: ""
    property bool error: false
    signal closed()

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(42, text.implicitHeight + 18)
    radius: Theme.radius
    color: banner.error ? Theme.dangerBackground : Theme.successBackground

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 4
        implicitHeight: parent.height - 16
        radius: 2
        color: banner.error ? Theme.dangerForeground : Theme.successForeground
    }

    Label {
        id: text
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 44
        text: banner.message
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
        color: banner.error ? Theme.dangerForeground : Theme.successForeground
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        color: closeArea.containsMouse ? Qt.rgba(0, 0, 0, 0.07) : "transparent"
        Label {
            anchors.centerIn: parent
            text: "×"
            textFormat: Text.PlainText
            color: banner.error ? Theme.dangerForeground : Theme.successForeground
            font.pixelSize: 14
        }
        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: banner.closed()
        }
    }
}
