import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

ColumnLayout {
    id: root
    property string label
    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias maximumLength: field.maximumLength
    property alias echoMode: field.echoMode
    property alias readOnly: field.readOnly
    signal accepted()

    spacing: 5
    Layout.fillWidth: true

    Label {
        text: root.label
        color: Theme.textSecondary
        font.pixelSize: 14
        textFormat: Text.PlainText
    }

    TextField {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.fieldHeight
        Accessible.name: root.label
        font.pixelSize: 15
        color: Theme.inputText
        placeholderTextColor: Theme.inputPlaceholder
        selectByMouse: true
        padding: 11
        onAccepted: root.accepted()

        background: Rectangle {
            radius: Theme.radius
            color: Theme.surface
            border.color: field.activeFocus ? Theme.primaryFocus : Theme.inputBorder
            border.width: field.activeFocus ? 2 : 1
        }
    }
}
