import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
        color: "#40535e"
        font.pixelSize: 14
        textFormat: Text.PlainText
    }

    TextField {
        id: field
        Layout.fillWidth: true
        Layout.preferredHeight: 43
        Accessible.name: root.label
        font.pixelSize: 15
        color: "#162e38"
        placeholderTextColor: "#6b7f89"
        selectByMouse: true
        padding: 11
        onAccepted: root.accepted()

        background: Rectangle {
            radius: 7
            color: "#ffffff"
            border.color: field.activeFocus ? "#12796e" : "#cad8de"
            border.width: field.activeFocus ? 2 : 1
        }
    }
}
