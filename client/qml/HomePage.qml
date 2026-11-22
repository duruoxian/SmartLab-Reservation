import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 首页：欢迎卡 + 快捷入口。F03 设备浏览接入后快捷入口逐个启用。
PageShell {
    id: root

    title: "首页"

    signal navigate(string key)

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 16

        SectionCard {
            Layout.fillWidth: true
            Layout.minimumWidth: 320
            Layout.fillHeight: true
            Layout.minimumHeight: 190

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Label {
                    text: "你好，" + (viewModel.user.name || "")
                    textFormat: Text.PlainText
                    color: Theme.textPrimary
                    font.pixelSize: 25
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: Theme.textMuted
                    text: viewModel.user.role === "admin"
                          ? "可以在角色管理中查询账号和调整权限。"
                          : "账号已登录。设备浏览与预约功能将随后续模块逐步开放。"
                }
                Button {
                    text: viewModel.user.role === "admin" ? "打开角色管理" : "查看个人资料"
                    highlighted: true
                    enabled: !viewModel.busy
                    onClicked: root.navigate(viewModel.user.role === "admin" ? "roles" : "profile")
                }
                Item { Layout.fillHeight: true }
            }
        }

        SectionCard {
            Layout.preferredWidth: 340
            Layout.fillHeight: true
            Layout.minimumHeight: 190
            title: "快捷入口"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        { name: "设备浏览", module: "M02", ready: false },
                        { name: "我的预约", module: "M03", ready: false },
                        { name: "消息中心", module: "M05", ready: false },
                    ]

                    delegate: RowLayout {
                        id: entry
                        required property var modelData
                        readonly property bool enabled1: entry.modelData.ready && !viewModel.busy

                        Layout.fillWidth: true
                        implicitHeight: 38

                        Rectangle {
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 8
                            color: entry.enabled1 ? Theme.tint(Theme.primary, 0.14) : Theme.surfaceHover
                            Label {
                                anchors.centerIn: parent
                                text: entry.modelData.module
                                textFormat: Text.PlainText
                                color: entry.enabled1 ? Theme.primary : Theme.textFaint
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.leftMargin: 6
                            text: entry.modelData.name
                            textFormat: Text.PlainText
                            color: entry.enabled1 ? Theme.textPrimary : Theme.textFaint
                        }
                        Label {
                            text: entry.enabled1 ? "进入" : "规划中"
                            textFormat: Text.PlainText
                            color: entry.enabled1 ? Theme.primary : Theme.textFaint
                            font.pixelSize: 12
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
