import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 首页：欢迎卡 + 快捷入口 + 后续模块路线图。
// 条目可点击跳转到对应页面（按角色判定）；模块接入后将 ready 置真并移除路线图条目。
PageShell {
    id: root

    title: "首页"

    signal navigate(string key)

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            SectionCard {
                Layout.fillWidth: true
                Layout.minimumWidth: 320
                Layout.preferredHeight: 216

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: "今天是 " + new Date().toLocaleDateString(Qt.locale("zh_CN"), "yyyy年M月d日 dddd")
                        textFormat: Text.PlainText
                        color: Theme.textFaint
                        font.pixelSize: 12
                    }
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
                    AppButton {
                        variant: "filled"
                        text: viewModel.user.role === "admin" ? "打开角色管理" : "查看个人资料"
                        enabled: !viewModel.busy
                        onClicked: root.navigate(viewModel.user.role === "admin" ? "roles" : "profile")
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            SectionCard {
                Layout.preferredWidth: 340
                Layout.preferredHeight: 216
                title: "快捷入口"

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: [
                            { key: "equipment", module: "M02", name: "设备浏览", roles: ["student", "teacher", "admin"] },
                            { key: "myReservations", module: "M03", name: "我的预约", roles: ["student", "teacher", "admin"] },
                            { key: "notifications", module: "M05", name: "消息中心", roles: ["student", "teacher", "admin"] },
                        ]

                    delegate: ItemDelegate {
                        id: entry
                        required property var modelData
                        readonly property bool clickable: entry.modelData.roles.indexOf(viewModel.user.role) >= 0

                        Layout.fillWidth: true
                        implicitHeight: 40
                        hoverEnabled: !viewModel.busy
                        opacity: clickable ? 1 : 0.55
                        onClicked: root.navigate(entry.modelData.key)

                        contentItem: RowLayout {
                            spacing: 8

                            Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 8
                                color: entry.clickable ? Theme.tint(Theme.primary, 0.12) : Theme.surfaceHover
                                Label {
                                    anchors.centerIn: parent
                                    text: entry.modelData.module
                                    textFormat: Text.PlainText
                                    color: entry.clickable ? Theme.primary : Theme.textFaint
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                text: entry.modelData.name
                                textFormat: Text.PlainText
                                color: entry.clickable ? Theme.textPrimary : Theme.textFaint
                                font.pixelSize: 14
                            }
                            Label {
                                text: "规划中"
                                textFormat: Text.PlainText
                                color: Theme.textFaint
                                font.pixelSize: 12
                            }
                            Label {
                                text: "›"
                                textFormat: Text.PlainText
                                color: Theme.primary
                                font.pixelSize: 15
                            }
                        }
                        background: Rectangle {
                            radius: Theme.radius
                            color: entry.hovered ? Theme.surfaceHover : "transparent"
                        }
                    }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        SectionCard {
            Layout.fillWidth: true
            title: "后续模块计划"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: [
                        { key: "approval", module: "M04", name: "审批与签到归还", desc: "预约审批、签到归还、逾期确认与违约处理", roles: ["admin"] },
                        { key: "notifications", module: "M05", name: "消息通知", desc: "站内消息、公告发布与已读管理", roles: ["student", "teacher", "admin"] },
                        { key: "admin", module: "M06", name: "后台管理", desc: "设备台账、实验室管理、账号启停与操作日志", roles: ["admin"] },
                        { key: "stats", module: "M07", name: "统计报表", desc: "使用率、预约量、违约率与审批通过率图表", roles: ["admin"] },
                    ]

                    delegate: ItemDelegate {
                        id: plan
                        required property var modelData
                        readonly property bool clickable: plan.modelData.roles.indexOf(viewModel.user.role) >= 0

                        Layout.fillWidth: true
                        implicitHeight: 46
                        hoverEnabled: !viewModel.busy
                        opacity: clickable ? 1 : 0.55
                        onClicked: root.navigate(plan.modelData.key)

                        contentItem: RowLayout {
                            spacing: 8

                            Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 8
                                color: plan.clickable ? Theme.tint(Theme.primary, 0.12) : Theme.surfaceHover
                                Label {
                                    anchors.centerIn: parent
                                    text: plan.modelData.module
                                    textFormat: Text.PlainText
                                    color: plan.clickable ? Theme.primary : Theme.textFaint
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Label {
                                    text: plan.modelData.name
                                    textFormat: Text.PlainText
                                    color: plan.clickable ? Theme.textPrimary : Theme.textFaint
                                    font.pixelSize: 14
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: plan.modelData.desc
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                }
                            }
                            Label {
                                text: "规划中"
                                textFormat: Text.PlainText
                                color: Theme.textFaint
                                font.pixelSize: 12
                            }
                            Label {
                                text: "›"
                                textFormat: Text.PlainText
                                color: Theme.primary
                                font.pixelSize: 15
                            }
                        }
                        background: Rectangle {
                            radius: Theme.radius
                            color: plan.hovered ? Theme.surfaceHover : "transparent"
                        }
                    }
                }
            }
        }
    }
}
