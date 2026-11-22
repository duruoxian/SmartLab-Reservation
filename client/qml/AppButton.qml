import QtQuick
import QtQuick.Controls
import SmartLab.ui

// 统一按钮：variant = filled（主色实心）/ tonal（主色浅底）/ text（透明）/ danger（浅红）。
// compact 为真时用于紧凑位置（表单内、分页条）。
Button {
    id: control

    property string variant: "filled"
    property bool compact: false

    implicitHeight: 40
    implicitWidth: Math.max(contentLabel.implicitWidth + (compact ? 20 : 36), compact ? 64 : 104)
    horizontalPadding: compact ? 10 : 18
    hoverEnabled: true

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    contentItem: Label {
        id: contentLabel
        text: control.text
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: !control.enabled ? Theme.inputPlaceholder
             : control.variant === "filled" ? "white"
             : control.variant === "tonal" ? Theme.primary
             : control.variant === "danger" ? Theme.dangerForeground
             : control.down ? Theme.textPrimary : Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: control.variant === "filled"
    }

    background: Rectangle {
        radius: Theme.radius
        color: !control.enabled ? Theme.disabledSurface
             : control.variant === "filled" ? (control.down ? Theme.primaryPressed
                                                            : control.hovered ? Theme.primaryHover : Theme.primary)
             : control.variant === "tonal" ? (control.down ? Theme.tint(Theme.primary, 0.24)
                                                           : control.hovered ? Theme.tint(Theme.primary, 0.18)
                                                                           : Theme.tint(Theme.primary, 0.10))
             : control.variant === "danger" ? (control.down ? Theme.tint(Theme.dangerForeground, 0.22)
                                                            : control.hovered ? Theme.tint(Theme.dangerForeground, 0.15)
                                                                            : Theme.tint(Theme.dangerForeground, 0.10))
             : (control.hovered ? Theme.surfaceHover : "transparent")
        border.color: control.visualFocus && control.variant === "filled" ? Theme.primaryFocus : "transparent"
        border.width: control.visualFocus && control.variant === "filled" ? 2 : 0
    }
}
