import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

ColumnLayout {
    id: root
    spacing: 12
    property string searchText: ""
    readonly property var roleCodes: ["student", "teacher", "admin"]
    readonly property var roleLabels: ["学生", "教师", "管理员"]

    Component.onCompleted: viewModel.loadAccounts("", 1)

    RowLayout {
        Layout.fillWidth: true
        TextField {
            id: search
            objectName: "roleSearch"
            Layout.fillWidth: true
            Accessible.name: "搜索账号或姓名"
            placeholderText: "搜索学号、工号或姓名"
            maximumLength: 60
            onAccepted: submitSearch()
            function submitSearch() {
                if (!viewModel.busy) {
                    root.searchText = text
                    viewModel.loadAccounts(root.searchText, 1)
                }
            }
        }
        Button {
            objectName: "roleSearchSubmit"
            text: "搜索"
            enabled: !viewModel.busy
            onClicked: search.submitSearch()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.surface
        radius: 9
        border.color: Theme.surfaceBorder

        ListView {
            id: users
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            model: viewModel.accounts
            spacing: 3
            ScrollBar.vertical: ScrollBar {}

            delegate: ItemDelegate {
                id: row
                required property var modelData
                width: users.width - 9
                padding: 9
                contentItem: RowLayout {
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: row.modelData.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            font.bold: true
                        }
                        Label {
                            Layout.fillWidth: true
                            text: row.modelData.user_no + "  ·  " + row.modelData.status
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: Theme.textMuted
                        }
                    }
                    ComboBox {
                        id: role
                        objectName: "roleChoice" + row.modelData.id
                        Accessible.name: "用户角色"
                        model: root.roleLabels
                        currentIndex: root.roleCodes.indexOf(row.modelData.role)
                        enabled: !viewModel.busy && row.modelData.id !== viewModel.user.id
                    }
                    Button {
                        objectName: "roleSave" + row.modelData.id
                        text: row.modelData.id === viewModel.user.id ? "当前用户" : "保存角色"
                        enabled: role.enabled && root.roleCodes[role.currentIndex] !== row.modelData.role
                        onClicked: viewModel.changeRole(row.modelData.id, root.roleCodes[role.currentIndex])
                    }
                }
                background: Rectangle { radius: 5; color: row.hovered ? Theme.surfaceHover : "white" }
            }
        }

        Label {
            anchors.centerIn: parent
            visible: viewModel.accounts.length === 0
            text: viewModel.busy ? "正在加载账号…" : "没有匹配的账号"
            color: Theme.textMuted
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        Button {
            text: "上一页"
            enabled: !viewModel.busy && viewModel.page > 1
            onClicked: viewModel.loadAccounts(root.searchText, viewModel.page - 1)
        }
        Label { text: "第 " + viewModel.page + " 页" }
        Button {
            text: "下一页"
            enabled: !viewModel.busy && viewModel.hasMore
            onClicked: viewModel.loadAccounts(root.searchText, viewModel.page + 1)
        }
    }
}
