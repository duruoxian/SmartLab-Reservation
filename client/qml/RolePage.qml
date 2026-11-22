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
            Layout.preferredWidth: 360
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
        Item { Layout.fillWidth: true }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Theme.surface
        radius: 9
        border.color: Theme.surfaceBorder

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.topMargin: 4
                Layout.bottomMargin: 8
                spacing: 10

                Label {
                    Layout.fillWidth: true
                    text: "姓名 / 账号状态"
                    textFormat: Text.PlainText
                    color: Theme.textFaint
                    font.pixelSize: 12
                    font.bold: true
                }
                Label {
                    Layout.preferredWidth: 130
                    text: "角色"
                    textFormat: Text.PlainText
                    color: Theme.textFaint
                    font.pixelSize: 12
                    font.bold: true
                }
                Label {
                    Layout.preferredWidth: 96
                    text: "操作"
                    textFormat: Text.PlainText
                    color: Theme.textFaint
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.surfaceBorder
                opacity: 0.6
            }

            ListView {
                id: users
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: viewModel.accounts
                spacing: 2
                ScrollBar.vertical: ScrollBar {}

                delegate: ItemDelegate {
                    id: row
                    required property var modelData
                    width: users.width
                    height: 56
                    padding: 8
                    contentItem: RowLayout {
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                font.bold: true
                                color: Theme.textPrimary
                            }
                            RowLayout {
                                spacing: 6
                                Label {
                                    text: row.modelData.user_no
                                    textFormat: Text.PlainText
                                    color: Theme.textMuted
                                    font.pixelSize: 12
                                }
                                Rectangle {
                                    implicitWidth: statusLabel.implicitWidth + 12
                                    implicitHeight: 18
                                    radius: 9
                                    color: row.modelData.status === "启用"
                                           ? Theme.tint(Theme.successForeground, 0.12)
                                           : Theme.tint(Theme.dangerForeground, 0.12)
                                    Label {
                                        id: statusLabel
                                        anchors.centerIn: parent
                                        text: row.modelData.status
                                        textFormat: Text.PlainText
                                        color: row.modelData.status === "启用" ? Theme.successForeground : Theme.dangerForeground
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                        ComboBox {
                            id: role
                            objectName: "roleChoice" + row.modelData.id
                            Accessible.name: "用户角色"
                            Layout.preferredWidth: 130
                            model: root.roleLabels
                            currentIndex: root.roleCodes.indexOf(row.modelData.role)
                            enabled: !viewModel.busy && row.modelData.id !== viewModel.user.id
                        }
                        Button {
                            objectName: "roleSave" + row.modelData.id
                            Layout.preferredWidth: 96
                            text: row.modelData.id === viewModel.user.id ? "当前用户" : "保存角色"
                            enabled: role.enabled && root.roleCodes[role.currentIndex] !== row.modelData.role
                            onClicked: viewModel.changeRole(row.modelData.id, root.roleCodes[role.currentIndex])
                        }
                    }
                    background: Rectangle {
                        radius: 5
                        color: row.hovered ? Theme.surfaceHover : "transparent"
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                visible: viewModel.accounts.length === 0
                text: viewModel.busy ? "正在加载账号…" : "没有匹配的账号"
                color: Theme.textMuted
            }
        }
    }

    PaginationBar {
        Layout.alignment: Qt.AlignRight
        page: viewModel.page
        hasMore: viewModel.hasMore
        busy: viewModel.busy
        onPageRequested: function (page) { viewModel.loadAccounts(root.searchText, page) }
    }
}
