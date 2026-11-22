import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 通用确认对话框：自绘卡片（标题 / 说明 / 取消 + 确认），danger 时确认按钮为浅红。
Dialog {
    id: dialog

    property string message: ""
    property bool danger: false
    signal confirmed()

    anchors.centerIn: parent
    width: 440
    modal: true
    padding: 0

    background: Rectangle {
        radius: 14
        color: Theme.surface
        border.color: Theme.surfaceBorder
    }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            Layout.margins: 20
            Layout.bottomMargin: 12
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: dialog.danger ? "请再次确认" : "确认操作"
                textFormat: Text.PlainText
                color: Theme.textPrimary
                font.pixelSize: 16
                font.bold: true
            }
            AppButton {
                variant: "text"
                compact: true
                implicitHeight: 30
                text: "×"
                onClicked: dialog.reject()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.divider
        }

        Label {
            Layout.margins: 20
            Layout.fillWidth: true
            text: dialog.message
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: dialog.danger ? Theme.dangerForeground : Theme.textSecondary
        }

        RowLayout {
            Layout.margins: 20
            Layout.topMargin: 4
            Layout.alignment: Qt.AlignRight
            spacing: 8

            AppButton {
                variant: "text"
                text: "取消"
                onClicked: dialog.reject()
            }
            AppButton {
                variant: dialog.danger ? "danger" : "filled"
                text: "确认"
                onClicked: {
                    dialog.accept()
                    dialog.confirmed()
                }
            }
        }
    }
}
