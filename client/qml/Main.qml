import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 1120
    height: 770
    minimumWidth: 860
    minimumHeight: 640
    visible: true
    title: "智约实验室设备预约系统"
    color: "#edf3f5"
    font.family: "Microsoft YaHei UI"
    font.pixelSize: 14
    palette.highlight: "#13766a"

    property string page: "home"
    readonly property bool admin: viewModel.user.role === "admin"
    readonly property var roleNames: ({student: "学生", teacher: "教师", admin: "管理员"})

    Loader {
        anchors.fill: parent
        sourceComponent: viewModel.loggedIn ? workspacePage : authPage
    }

    Connections {
        target: viewModel
        function onUserChanged() {
            if (!viewModel.loggedIn || (window.page === "roles" && !window.admin))
                window.page = "home"
        }
        function onRecoveryCodeReady(code) {
            recoveryValue.text = code
            recoveryDialog.open()
        }
    }

    Dialog {
        id: recoveryDialog
        objectName: "recoveryDialog"
        anchors.centerIn: parent
        width: 460
        title: "保存你的恢复码"
        modal: true
        standardButtons: Dialog.Ok
        closePolicy: Popup.NoAutoClose
        onClosed: recoveryValue.clear()

        ColumnLayout {
            width: parent.width
            spacing: 12
            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "恢复码只显示这一次。请复制后保存在安全的地方，找回密码时需要使用。"
            }
            TextField {
                id: recoveryValue
                objectName: "recoveryValue"
                Layout.fillWidth: true
                readOnly: true
                selectByMouse: true
                Accessible.name: "一次性恢复码"
                font.family: "Consolas"
            }
            Button {
                text: "复制恢复码"
                onClicked: {
                    recoveryValue.selectAll()
                    recoveryValue.copy()
                }
            }
        }
    }

    Component {
        id: authPage
        AuthPage {}
    }

    Component {
        id: workspacePage
        RowLayout {
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: "#13363c"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 9

                    Label { text: "智约"; color: "white"; font.pixelSize: 32; font.bold: true }
                    Label { text: "实验室设备预约系统"; color: "#b7d8d3"; font.pixelSize: 14 }
                    Item { Layout.preferredHeight: 24 }
                    Button {
                        text: "首页"
                        Layout.fillWidth: true
                        highlighted: window.page === "home"
                        enabled: !viewModel.busy
                        onClicked: {
                            viewModel.clearMessage()
                            window.page = "home"
                        }
                    }
                    Button {
                        text: "个人中心"
                        objectName: "profileNavigation"
                        Layout.fillWidth: true
                        highlighted: window.page === "profile"
                        enabled: !viewModel.busy
                        onClicked: {
                            window.page = "profile"
                            viewModel.refreshProfile()
                        }
                    }
                    Button {
                        text: "角色管理"
                        objectName: "rolesNavigation"
                        Layout.fillWidth: true
                        visible: window.admin
                        highlighted: window.page === "roles"
                        enabled: !viewModel.busy
                        onClicked: window.page = "roles"
                    }
                    Item { Layout.fillHeight: true }
                    Label {
                        text: viewModel.user.name || ""
                        textFormat: Text.PlainText
                        color: "white"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.bold: true
                    }
                    Label { text: window.roleNames[viewModel.user.role] || ""; color: "#b7d8d3" }
                    Button {
                        text: "退出登录"
                        objectName: "logoutButton"
                        Layout.fillWidth: true
                        enabled: !viewModel.busy
                        onClicked: viewModel.logout()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 59
                    color: "#ffffff"
                    Label {
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        text: window.page === "profile" ? "个人中心"
                              : window.page === "roles" ? "角色管理"
                              : window.admin ? "管理工作台" : "设备浏览"
                        color: "#173440"
                        font.pixelSize: 19
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 24
                    Layout.rightMargin: 24
                    Layout.topMargin: visible ? 14 : 0
                    Layout.preferredHeight: statusText.implicitHeight + 16
                    visible: viewModel.message.length > 0
                    radius: 7
                    color: viewModel.error ? "#fff0ed" : "#e4f4ec"
                    Label {
                        id: statusText
                        anchors.fill: parent
                        anchors.margins: 8
                        text: viewModel.message
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: viewModel.error ? "#9f3c2f" : "#176449"
                    }
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 24
                    sourceComponent: window.page === "profile" ? profilePage
                                     : window.page === "roles" ? rolePage : homePage
                }
            }
        }
    }

    Component { id: profilePage; ProfilePage {} }
    Component { id: rolePage; RolePage {} }

    Component {
        id: homePage
        Item {
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 182
                radius: 12
                color: "#ffffff"
                border.color: "#d9e5e8"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 8
                    Label {
                        text: "你好，" + (viewModel.user.name || "")
                        textFormat: Text.PlainText
                        color: "#173440"
                        font.pixelSize: 26
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        color: "#4a626d"
                        text: window.admin ? "可以在角色管理中查询账号和调整权限。"
                                           : "账号已登录。设备列表将在 M02 模块接入。"
                    }
                    Button {
                        text: window.admin ? "打开角色管理" : "查看个人资料"
                        enabled: !viewModel.busy
                        onClicked: {
                            window.page = window.admin ? "roles" : "profile"
                            if (!window.admin)
                                viewModel.refreshProfile()
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
