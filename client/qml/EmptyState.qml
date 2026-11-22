import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 模块未接入时的空状态：徽标 + 标题 + 说明 + 功能清单 + 范围注记。
Rectangle {
    id: state

    property string module: ""
    property string title: ""
    property string description: ""
    property var features: []
    property string note: ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: 300
    radius: Theme.radiusLarge
    color: Theme.surface
    border.color: Theme.surfaceBorder

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 72, 500)
        spacing: 14

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 58
            implicitHeight: 58
            radius: 15
            color: state.module.length > 0 ? Theme.tint(Theme.primary, 0.12) : Theme.surfaceHover
            border.color: state.module.length > 0 ? Theme.tint(Theme.primary, 0.24) : Theme.surfaceBorder
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

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            visible: state.features.length > 0
            spacing: 8

            Repeater {
                model: state.features

                delegate: RowLayout {
                    id: feature
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: Theme.tint(Theme.primary, 0.12)
                        Label {
                            anchors.centerIn: parent
                            text: "✓"
                            textFormat: Text.PlainText
                            color: Theme.primary
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        text: feature.modelData
                        textFormat: Text.PlainText
                        color: Theme.textSecondary
                        font.pixelSize: 13
                    }
                }
            }
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
