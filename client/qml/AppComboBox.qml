import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 统一下拉框：自绘背景、指示符、弹层与选中标记，支持字符串数组与对象数组（textRole）。
ComboBox {
    id: control

    implicitHeight: Theme.fieldHeight
    hoverEnabled: true
    font.family: Theme.fontFamily
    font.pixelSize: 14

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    delegate: ItemDelegate {
        id: itemDelegate
        width: control.width
        hoverEnabled: control.popup.visible
        contentItem: RowLayout {
            spacing: 6
            Label {
                Layout.fillWidth: true
                text: control.textRole ? model[control.textRole] : modelData
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: itemDelegate.highlighted ? Theme.primary : Theme.inputText
                font.pixelSize: 14
            }
            Label {
                text: "✓"
                textFormat: Text.PlainText
                visible: control.currentIndex === itemDelegate.index
                color: Theme.primary
                font.pixelSize: 13
                font.bold: true
            }
        }
        background: Rectangle {
            radius: 6
            color: itemDelegate.hovered ? Theme.surfaceHover : "transparent"
        }
    }

    indicator: Label {
        x: control.width - width - 14
        y: control.topPadding + (control.availableHeight - height) / 2
        text: "▾"
        textFormat: Text.PlainText
        color: Theme.textSecondary
        font.pixelSize: 14
    }

    contentItem: Label {
        text: control.displayText
        textFormat: Text.PlainText
        verticalAlignment: Text.AlignVCenter
        leftPadding: 12
        rightPadding: 34
        color: Theme.inputText
        font.family: Theme.fontFamily
        font.pixelSize: 14
    }

    background: Rectangle {
        radius: Theme.radius
        color: Theme.surface
        border.color: control.activeFocus || control.popup.visible ? Theme.primaryFocus
                                                                   : control.hovered ? Theme.inputBorderHover : Theme.inputBorder
        border.width: control.activeFocus || control.popup.visible ? 2 : 1
    }

    popup: Popup {
        y: control.height + 6
        width: control.width
        padding: 4
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 320)

        background: Rectangle {
            radius: 10
            color: Theme.surface
            border.color: Theme.surfaceBorder
        }

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
    }
}
