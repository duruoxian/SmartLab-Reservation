import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 模块未接入时的空状态占位：模块徽标 + 标题 + 说明 + 覆盖范围。
Rectangle {
    id: state

    property string module: ""
    property string title: ""
    property string description: ""
    property string note: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: 280
    radius: Theme.radiusLarge
    color: Theme.surface
    border.color: Theme.surfaceBorder

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 64, 460)
        spacing: 12

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 56
            implicitHeight: 56
            radius: 14
            color: state.module.length > 0 ? Theme.tint(Theme.primary, 0.12) : Theme.surfaceHover
            Label {
                anchors.centerIn: parent
                visible: state.module.length > 0
                text: state.module
                textFormat: Text.PlainText
                color: Theme.primary
                font.pixelSize: 17
                font.bold: true
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: state.title
            textFormat: Text.PlainText
            color: Theme.textPrimary
            font.pixelSize: 17
            font.bold: true
        }

        Label {
            Layout.fillWidth: true
            text: state.description
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textMuted
        }

        Label {
            Layout.fillWidth: true
            visible: state.note.length > 0
            text: state.note
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textFaint
            font.pixelSize: 12
        }
    }
}
