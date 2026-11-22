import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 统一页面框架：页头（标题/副标题/徽标/操作区）+ 内容区。
// 业务页只负责填充内容；标题与徽标由页面自己声明，导航壳不再维护全局页头。
ColumnLayout {
    id: shell

    property string title: ""
    property string subtitle: ""
    // 模块徽标，如 "M02 · 规划中"；留空则不显示
    property string badge: ""
    // 页头右侧操作区
    property alias actions: actionsRow.data
    // 页面主体内容
    default property alias content: body.data

    spacing: 14

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Label {
                text: shell.title
                textFormat: Text.PlainText
                color: Theme.textPrimary
                font.pixelSize: 19
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                visible: shell.subtitle.length > 0
                text: shell.subtitle
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: Theme.textMuted
                font.pixelSize: 12
            }
        }

        Rectangle {
            visible: shell.badge.length > 0
            implicitWidth: badgeLabel.implicitWidth + 16
            implicitHeight: 22
            radius: 11
            color: Theme.tint(Theme.primary, 0.12)
            Label {
                id: badgeLabel
                anchors.centerIn: parent
                text: shell.badge
                textFormat: Text.PlainText
                color: Theme.primary
                font.pixelSize: 11
                font.bold: true
            }
        }

        RowLayout { id: actionsRow; spacing: 8 }
    }

    ColumnLayout {
        id: body
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 14
    }
}
