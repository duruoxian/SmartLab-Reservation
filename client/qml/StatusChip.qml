import QtQuick
import QtQuick.Controls
import SmartLab.ui

// 状态徽章：tone = success / danger / warning / neutral / primary。
Rectangle {
    id: chip

    property string text: ""
    property string tone: "neutral"

    implicitWidth: label.implicitWidth + 14
    implicitHeight: 20
    radius: 10
    color: chip.tone === "success" ? Theme.tint(Theme.successForeground, 0.12)
         : chip.tone === "danger" ? Theme.tint(Theme.dangerForeground, 0.12)
         : chip.tone === "warning" ? Theme.warningBackground
         : chip.tone === "primary" ? Theme.tint(Theme.primary, 0.12)
         : Theme.surfaceHover

    Label {
        id: label
        anchors.centerIn: parent
        text: chip.text
        textFormat: Text.PlainText
        color: chip.tone === "success" ? Theme.successForeground
             : chip.tone === "danger" ? Theme.dangerForeground
             : chip.tone === "warning" ? Theme.warningForeground
             : chip.tone === "primary" ? Theme.primary
             : Theme.textMuted
        font.pixelSize: 10
        font.bold: true
    }
}
