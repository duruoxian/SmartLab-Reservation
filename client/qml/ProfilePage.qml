import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    function fillProfile() {
        college.text = viewModel.user.college || ""
        major.text = viewModel.user.major || ""
        phone.text = viewModel.user.phone || ""
    }

    Component.onCompleted: fillProfile()
    Connections {
        target: viewModel
        function onUserChanged() { root.fillProfile() }
        function onRecoveryCodeReady(code) { currentPassword.text = "" }
    }

    ColumnLayout {
        width: root.availableWidth
        spacing: 15

        SectionCard {
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    implicitWidth: 54
                    implicitHeight: 54
                    radius: 27
                    color: Theme.tint(Theme.primary, 0.12)
                    border.color: Theme.tint(Theme.primary, 0.26)
                    Label {
                        anchors.centerIn: parent
                        text: (viewModel.user.name || "?").charAt(0)
                        textFormat: Text.PlainText
                        color: Theme.primary
                        font.pixelSize: 21
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    RowLayout {
                        spacing: 10
                        Label {
                            text: viewModel.user.name || "未登录"
                            textFormat: Text.PlainText
                            color: Theme.textPrimary
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Label {
                            text: viewModel.user.user_no || ""
                            textFormat: Text.PlainText
                            visible: viewModel.loggedIn
                            color: Theme.textMuted
                            font.pixelSize: 13
                        }
                    }

                    RowLayout {
                        spacing: 8

                        StatusChip {
                            text: viewModel.user.booking_frozen ? "预约权限已冻结" : "预约权限正常"
                            tone: viewModel.user.booking_frozen ? "danger" : "success"
                        }
                        StatusChip {
                            text: "违约 " + (viewModel.user.violation_count || 0) + " 次"
                            tone: (viewModel.user.violation_count || 0) > 0 ? "warning" : "neutral"
                        }
                        Label {
                            visible: viewModel.user.booking_frozen && viewModel.user.frozen_until
                            text: "解冻时间：" + Qt.formatDateTime(new Date(viewModel.user.frozen_until * 1000), "yyyy-MM-dd hh:mm")
                            textFormat: Text.PlainText
                            color: Theme.textMuted
                            font.pixelSize: 12
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        SectionCard {
            title: "基本资料"
            Layout.fillWidth: true

            GridLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 640
                columns: 2
                columnSpacing: 12
                FormField { id: college; objectName: "profileCollege"; label: "学院"; maximumLength: 60 }
                FormField { id: major; objectName: "profileMajor"; label: "专业"; maximumLength: 60 }
                FormField { id: phone; objectName: "profilePhone"; label: "预留手机号"; maximumLength: 11 }
            }
            AppButton {
                objectName: "profileSave"
                variant: "filled"
                text: "保存资料"
                enabled: !viewModel.busy
                onClicked: viewModel.updateProfile({college: college.text, major: major.text, phone: phone.text})
            }
        }

        SectionCard {
            title: "账号安全"
            Layout.fillWidth: true

            FormField {
                id: currentPassword
                objectName: "profileCurrentPassword"
                label: "当前密码"
                maximumLength: 32
                echoMode: TextInput.Password
            }
            GridLayout {
                Layout.fillWidth: true
                Layout.maximumWidth: 640
                columns: 2
                columnSpacing: 12
                FormField { id: newPassword; objectName: "profileNewPassword"; label: "新密码"; maximumLength: 32; echoMode: TextInput.Password }
                FormField { id: confirm; objectName: "profileConfirmPassword"; label: "确认新密码"; maximumLength: 32; echoMode: TextInput.Password }
            }
            RowLayout {
                spacing: 8
                AppButton {
                    objectName: "profileChangePassword"
                    variant: "filled"
                    text: "修改密码"
                    enabled: !viewModel.busy && currentPassword.text.length > 0
                    onClicked: viewModel.changePassword(currentPassword.text, newPassword.text, confirm.text)
                }
                AppButton {
                    variant: "tonal"
                    text: "生成新的恢复码"
                    enabled: !viewModel.busy && currentPassword.text.length > 0
                    onClicked: viewModel.renewRecoveryCode(currentPassword.text)
                }
            }
        }
    }
}
