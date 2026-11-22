import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 统一输入框：标签 + 自绘输入区（悬浮/聚焦/禁用态），密码字段内置显示切换。
ColumnLayout {
    id: root
    property string label
    property alias text: field.text
    property alias placeholderText: field.placeholderText
    property alias maximumLength: field.maximumLength
    property alias echoMode: field.echoMode
    property alias readOnly: field.readOnly
    signal accepted()

    readonly property bool isPassword: field.echoMode === TextInput.Password

    spacing: 5
    Layout.fillWidth: true

    Label {
        text: root.label
        color: Theme.textSecondary
        font.pixelSize: 13
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
        rightPadding: root.isPassword ? 66 : 11
        hoverEnabled: true
        onAccepted: root.accepted()

        background: Rectangle {
            radius: Theme.radius
            color: !field.enabled ? Theme.disabledSurface : Theme.surface
            border.color: field.activeFocus ? Theme.primaryFocus
                                            : field.hovered ? Theme.inputBorderHover : Theme.inputBorder
            border.width: field.activeFocus ? 2 : 1
        }

        AppButton {
            visible: root.isPassword
            variant: "text"
            compact: true
            implicitHeight: 30
            anchors.right: parent.right
            anchors.rightMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            text: field.echoMode === TextInput.Password ? "显示" : "隐藏"
            onClicked: field.echoMode = field.echoMode === TextInput.Password
                                        ? TextInput.Normal : TextInput.Password
        }
    }
}
