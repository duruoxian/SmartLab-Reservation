import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 白底圆角卡片容器：可选标题 + 任意内容。
Rectangle {
    id: card

    property string title: ""
    default property alias content: body.data

    radius: Theme.radiusLarge
    color: Theme.surface
    border.color: Theme.surfaceBorder
    implicitHeight: column.implicitHeight + 40

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            Layout.fillWidth: true
            visible: card.title.length > 0
            text: card.title
            textFormat: Text.PlainText
            color: Theme.textPrimary
            font.pixelSize: 15
            font.bold: true
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            spacing: 10
        }
    }
}
