import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

Item {
    id: root

    component AuthTab: TabButton {
        id: tab
        implicitHeight: 41
        contentItem: Label {
            text: tab.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: tab.checked ? Theme.primaryChecked : Theme.textFaint
            font.bold: tab.checked
        }
        background: Rectangle {
            radius: 6
            color: tab.checked ? Theme.surface : "transparent"
            border.color: tab.activeFocus ? Theme.primary : "transparent"
        }
    }

    component SubmitButton: Button {
        id: button
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        enabled: !viewModel.busy
        contentItem: Label {
            text: button.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.bold: true
            color: button.enabled ? "white" : Theme.inputPlaceholder
        }
        background: Rectangle {
            radius: Theme.radius
            color: !button.enabled ? Theme.disabledSurface
                                   : button.down ? Theme.primaryPressed : Theme.primary
            border.color: button.activeFocus ? Theme.textPrimary : "transparent"
        }
    }

    Connections {
        target: viewModel
        function onRegistered(userNo) {
            root.rememberedNumber = userNo
            tabs.currentIndex = 0
        }
        function onPasswordReset(userNo) {
            root.rememberedNumber = userNo
            tabs.currentIndex = 0
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 0

        Rectangle {
            Layout.preferredWidth: root.width > 1000 ? 334 : 256
            Layout.fillHeight: true
            radius: Theme.radiusPanel
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.sidebarGradientTop }
                GradientStop { position: 1; color: Theme.sidebarGradientBottom }
            }
            Rectangle {
                anchors.right: parent.right
                width: 14
                height: parent.height
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.sidebarGradientTop }
                    GradientStop { position: 1; color: Theme.sidebarGradientBottom }
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 35
                spacing: 15
                Item { Layout.fillHeight: true }
                Label { text: "智约"; color: "white"; font.pixelSize: 56; font.bold: true }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "实验室设备\n预约管理系统"
                    color: Theme.sidebarBrand
                    font.pixelSize: 23
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "面向学生、教师和实验室管理员"
                    color: Theme.sidebarMuted
                    font.pixelSize: 14
                }
                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.surface
            radius: Theme.radiusPanel
            Rectangle {
                anchors.left: parent.left
                width: 14
                height: parent.height
                color: parent.color
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 29
                spacing: 13

                Label {
                    text: ["登录账号", "注册账号", "找回密码"][tabs.currentIndex]
                    color: Theme.textPrimary
                    font.pixelSize: 28
                    font.bold: true
                }

                TabBar {
                    id: tabs
                    objectName: "authTabs"
                    Layout.fillWidth: true
                    enabled: !viewModel.busy
                    padding: 4
                    spacing: 4
                    background: Rectangle { radius: 8; color: Theme.windowBackground }
                    AuthTab { text: "登录" }
                    AuthTab { text: "注册" }
                    AuthTab { text: "找回密码" }
                    onCurrentIndexChanged: {
                        viewModel.clearMessage()
                        if (currentIndex === 1 && viewModel.roles.length === 0)
                            viewModel.loadRoles()
                    }
                }

                Label {
                    Layout.fillWidth: true
                    visible: viewModel.message.length > 0
                    text: viewModel.message
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: viewModel.error ? Theme.dangerForeground : Theme.successForeground
                }

                ScrollView {
                    id: formScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Loader {
                        width: formScroll.availableWidth
                        sourceComponent: [loginForm, registerForm, resetForm][tabs.currentIndex]
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "智约 · 软件项目管理课程第 9 组"
                    textFormat: Text.PlainText
                    color: Theme.textFaint
                    font.pixelSize: 11
                }
            }
        }
    }

    property string rememberedNumber: ""
    Component {
        id: loginForm
        ColumnLayout {
            spacing: 15
            FormField {
                id: loginField
                objectName: "loginAccount"
                label: "学号或工号"
                placeholderText: "8 至 12 位字母或数字"
                maximumLength: 12
                text: root.rememberedNumber
            }
            FormField {
                id: loginPassword
                objectName: "loginPassword"
                label: "密码"
                echoMode: TextInput.Password
                onAccepted: viewModel.login(loginField.text, text)
            }
            SubmitButton {
                objectName: "loginSubmit"
                text: viewModel.busy ? "正在登录…" : "登录"
                onClicked: viewModel.login(loginField.text, loginPassword.text)
            }
        }
    }

    Component {
        id: registerForm
        ColumnLayout {
            spacing: 12
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 14
                rowSpacing: 10
                FormField { id: registerNumber; objectName: "registerAccount"; label: "学号或工号"; maximumLength: 12 }
                FormField { id: registerName; objectName: "registerName"; label: "姓名"; maximumLength: 20 }
                FormField { id: registerCollege; objectName: "registerCollege"; label: "学院"; maximumLength: 60 }
                FormField { id: registerMajor; objectName: "registerMajor"; label: "专业"; maximumLength: 60 }
                FormField { id: registerPhone; objectName: "registerPhone"; label: "预留手机号"; maximumLength: 11 }
                ColumnLayout {
                    Layout.fillWidth: true
                    Label { text: "角色"; color: Theme.textSecondary }
                    ComboBox {
                        id: roleChoice
                        objectName: "registerRole"
                        Accessible.name: "注册角色"
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.fieldHeight
                        model: viewModel.roles
                        textRole: "name"
                        valueRole: "code"
                    }
                }
                FormField {
                    id: registerPassword
                    objectName: "registerPassword"
                    label: "密码"
                    placeholderText: "8 至 32 位，包含字母和数字"
                    maximumLength: 32
                    echoMode: TextInput.Password
                }
                FormField { id: registerConfirm; objectName: "registerConfirm"; label: "确认密码"; maximumLength: 32; echoMode: TextInput.Password }
            }
            Button {
                text: "加载可注册角色"
                visible: viewModel.roles.length === 0 && !viewModel.busy
                onClicked: viewModel.loadRoles()
            }
            SubmitButton {
                objectName: "registerSubmit"
                text: viewModel.busy ? "正在提交…" : "创建账号"
                enabled: !viewModel.busy && roleChoice.currentIndex >= 0
                onClicked: viewModel.registerAccount({
                    user_no: registerNumber.text, name: registerName.text, role: roleChoice.currentValue,
                    college: registerCollege.text, major: registerMajor.text, phone: registerPhone.text,
                    password: registerPassword.text
                }, registerConfirm.text)
            }
        }
    }

    Component {
        id: resetForm
        ColumnLayout {
            spacing: 12
            Label { text: "使用注册时保存的一次性恢复码。"; color: Theme.textMuted }
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                columnSpacing: 14
                rowSpacing: 10
                FormField { id: resetNumber; objectName: "resetAccount"; label: "学号或工号"; maximumLength: 12 }
                FormField { id: resetPhone; objectName: "resetPhone"; label: "预留手机号"; maximumLength: 11 }
                FormField {
                    id: resetKey
                    objectName: "resetCode"
                    Layout.columnSpan: 2
                    label: "一次性恢复码"
                    maximumLength: 24
                    echoMode: TextInput.Password
                }
                FormField { id: nextPassword; objectName: "resetPassword"; label: "新密码"; maximumLength: 32; echoMode: TextInput.Password }
                FormField { id: nextConfirm; objectName: "resetConfirm"; label: "确认新密码"; maximumLength: 32; echoMode: TextInput.Password }
            }
            SubmitButton {
                objectName: "resetSubmit"
                text: viewModel.busy ? "正在提交…" : "重置密码"
                onClicked: viewModel.resetPassword({
                    user_no: resetNumber.text, phone: resetPhone.text, recovery_code: resetKey.text,
                    new_password: nextPassword.text
                }, nextConfirm.text)
            }
        }
    }
}
