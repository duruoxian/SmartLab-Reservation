import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 首页：欢迎卡 + 快捷入口 + 后续模块路线图。
// 各模块接入后：快捷入口置 ready 启用，路线图条目移除。
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
                        text: "今天是 " + Qt.formatDate(new Date(), "yyyy年M月d日 dddd", Qt.locale("zh_CN"))
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
                Layout.preferredHeight: 216
                title: "快捷入口"

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Repeater {
                        model: [
                            { module: "M02", name: "设备浏览" },
                            { module: "M03", name: "我的预约" },
                            { module: "M05", name: "消息中心" },
                        ]

                        delegate: RowLayout {
                            id: entry
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 38

                            Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 8
                                color: Theme.tint(Theme.primary, 0.12)
                                Label {
                                    anchors.centerIn: parent
                                    text: entry.modelData.module
                                    textFormat: Text.PlainText
                                    color: Theme.primary
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                Layout.leftMargin: 8
                                text: entry.modelData.name
                                textFormat: Text.PlainText
                                color: Theme.textPrimary
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
                                color: Theme.textFaint
                                font.pixelSize: 15
                                Layout.leftMargin: -6
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
                        { module: "M04", name: "审批与签到归还", desc: "预约审批、签到归还、逾期确认与违约处理" },
                        { module: "M05", name: "消息通知", desc: "站内消息、公告发布与已读管理" },
                        { module: "M06", name: "后台管理", desc: "设备台账、实验室管理、账号启停与操作日志" },
                        { module: "M07", name: "统计报表", desc: "使用率、预约量、违约率与审批通过率图表" },
                    ]

                    delegate: RowLayout {
                        id: plan
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 40

                        Rectangle {
                            implicitWidth: 26
                            implicitHeight: 26
                            radius: 8
                            color: Theme.surfaceHover
                            Label {
                                anchors.centerIn: parent
                                text: plan.modelData.module
                                textFormat: Text.PlainText
                                color: Theme.textFaint
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            spacing: 0
                            Label {
                                text: plan.modelData.name
                                textFormat: Text.PlainText
                                color: Theme.textPrimary
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
                    }
                }
            }
        }
    }
}
