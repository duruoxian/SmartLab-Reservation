import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 通用确认对话框：设置 message 后调用 open()，用户确认时发出 confirmed()。
Dialog {
    id: dialog

    property string message: ""
    property bool danger: false
    signal confirmed()

    anchors.centerIn: parent
    width: 430
    modal: true
    title: "请确认"

    ColumnLayout {
        width: parent.width
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: dialog.message
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            color: dialog.danger ? Theme.dangerForeground : Theme.textPrimary
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            Button {
                text: "取消"
                onClicked: dialog.reject()
            }
            Button {
                highlighted: true
                text: "确认"
                onClicked: {
                    dialog.accept()
                    dialog.confirmed()
                }
            }
        }
    }
}
