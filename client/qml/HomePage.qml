import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 首页：欢迎卡片 + 角色相关入口。F03 设备浏览接入后在此补充快捷入口。
PageShell {
    id: root

    title: "首页"

    signal navigate(string key)

    SectionCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 182

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Label {
                text: "你好，" + (viewModel.user.name || "")
                textFormat: Text.PlainText
                color: Theme.textPrimary
                font.pixelSize: 26
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                color: Theme.textMuted
                text: viewModel.user.role === "admin"
                      ? "可以在角色管理中查询账号和调整权限。"
                      : "账号已登录。设备列表将在 M02 模块接入。"
            }
            Button {
                text: viewModel.user.role === "admin" ? "打开角色管理" : "查看个人资料"
                enabled: !viewModel.busy
                onClicked: root.navigate(viewModel.user.role === "admin" ? "roles" : "profile")
            }
            Item { Layout.fillHeight: true }
        }
    }
}
