import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 业务结果提示条：绑定 viewModel.message / viewModel.error 即可。
Rectangle {
    id: banner

    property string message: ""
    property bool error: false

    Layout.fillWidth: true
    Layout.preferredHeight: Math.max(42, text.implicitHeight + 18)
    radius: Theme.radius
    color: banner.error ? Theme.dangerBackground : Theme.successBackground

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 4
        implicitHeight: parent.height - 14
        radius: 2
        color: banner.error ? Theme.dangerForeground : Theme.successForeground
    }

    Label {
        id: text
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 10
        text: banner.message
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
        color: banner.error ? Theme.dangerForeground : Theme.successForeground
    }
}
