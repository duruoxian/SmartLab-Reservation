import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

Item {
    id: root

    component AuthTab: TabButton {
        id: tab
        implicitHeight: 38
        contentItem: Label {
            text: tab.text
            textFormat: Text.PlainText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: tab.checked ? Theme.primary : Theme.textSecondary
            font.pixelSize: 14
            font.bold: tab.checked
        }
        background: Rectangle {
            radius: 8
            color: tab.checked ? Theme.surface : "transparent"
            border.color: tab.checked ? Theme.surfaceBorder : "transparent"
        }
    }

    component SubmitButton: AppButton {
        Layout.fillWidth: true
        implicitHeight: 44
        variant: "filled"
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
        spacing: 24

        Rectangle {
            Layout.preferredWidth: root.width > 1000 ? 334 : 256
            Layout.fillHeight: true
            clip: true
            radius: Theme.radiusPanel
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.sidebarGradientTop }
                GradientStop { position: 1; color: Theme.sidebarGradientBottom }
            }

            Rectangle {
                width: 240
                height: 240
                radius: 120
                color: Qt.rgba(1, 1, 1, 0.05)
                x: -70
                y: parent.height - 150
            }
            Rectangle {
                width: 150
                height: 150
                radius: 75
                color: Qt.rgba(1, 1, 1, 0.06)
                x: 190
                y: -50
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 35
                spacing: 14
                Item { Layout.fillHeight: true }

                Label { text: "智约"; color: "white"; font.pixelSize: 54; font.bold: true }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "实验室设备\n预约管理系统"
                    color: Theme.sidebarBrand
                    font.pixelSize: 22
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "面向学生、教师和实验室管理员"
                    color: Theme.sidebarMuted
                    font.pixelSize: 13
                }

                Item { Layout.preferredHeight: 8 }

                ColumnLayout {
                    spacing: 7

                    RowLayout {
                        spacing: 8
                        Label { text: "✓"; color: Theme.sidebarBrand; font.bold: true }
                        Label { text: "预约 · 审批 · 归还全流程线上化"; color: Theme.sidebarMuted; font.pixelSize: 12 }
                    }
                    RowLayout {
                        spacing: 8
                        Label { text: "✓"; color: Theme.sidebarBrand; font.bold: true }
                        Label { text: "违约记录与统计报表"; color: Theme.sidebarMuted; font.pixelSize: 12 }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.surface
            radius: Theme.radiusPanel
            border.color: Theme.surfaceBorder

            ColumnLayout {
                x: 29
                y: 29
                width: Math.min(parent.width - 58, 560)
                height: parent.height - 58
                spacing: 13

                Label {
                    text: ["登录账号", "注册账号", "找回密码"][tabs.currentIndex]
                    color: Theme.textPrimary
                    font.pixelSize: 27
                    font.bold: true
                }

                TabBar {
                    id: tabs
                    objectName: "authTabs"
                    Layout.fillWidth: true
                    enabled: !viewModel.busy
                    padding: 4
                    spacing: 4
                    background: Rectangle { radius: 10; color: Theme.surfaceSunken }
                    AuthTab { text: "登录" }
                    AuthTab { text: "注册" }
                    AuthTab { text: "找回密码" }
                    onCurrentIndexChanged: {
                        viewModel.clearMessage()
                        if (currentIndex === 1 && viewModel.roles.length === 0)
                            viewModel.loadRoles()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    visible: viewModel.message.length > 0
                    implicitHeight: authMessage.implicitHeight + 16
                    radius: 8
                    color: viewModel.error ? Theme.dangerBackground : Theme.successBackground

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: 4
                        implicitHeight: parent.height - 14
                        radius: 2
                        color: viewModel.error ? Theme.dangerForeground : Theme.successForeground
                    }

                    Label {
                        id: authMessage
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 10
                        text: viewModel.message
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        verticalAlignment: Text.AlignVCenter
                        color: viewModel.error ? Theme.dangerForeground : Theme.successForeground
                        font.pixelSize: 13
                    }
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
                    spacing: 5
                    Label { text: "角色"; color: Theme.textSecondary; font.pixelSize: 13 }
                    AppComboBox {
                        id: roleChoice
                        objectName: "registerRole"
                        Accessible.name: "注册角色"
                        Layout.fillWidth: true
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
            AppButton {
                variant: "text"
                visible: viewModel.roles.length === 0 && !viewModel.busy
                text: "加载可注册角色"
                Layout.alignment: Qt.AlignHCenter
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
            Label { text: "使用注册时保存的一次性恢复码。"; color: Theme.textMuted; font.pixelSize: 13 }
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
