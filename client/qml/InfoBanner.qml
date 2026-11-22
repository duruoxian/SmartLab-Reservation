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
    Layout.preferredHeight: Math.max(40, text.implicitHeight + 16)
    radius: Theme.radius
    color: banner.error ? Theme.dangerBackground : Theme.successBackground

    Label {
        id: text
        anchors.fill: parent
        anchors.margins: 8
        text: banner.message
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
        color: banner.error ? Theme.dangerForeground : Theme.successForeground
    }
}
