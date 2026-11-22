import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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

        Label {
            Layout.fillWidth: true
            text: (viewModel.user.name || "") + "  ·  " + (viewModel.user.user_no || "")
            textFormat: Text.PlainText
            color: "#173440"
            font.pixelSize: 22
            font.bold: true
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: "预约权限：" + (viewModel.user.booking_frozen ? "已冻结" : "正常")
                  + "   违约次数：" + (viewModel.user.violation_count || 0)
                  + (viewModel.user.booking_frozen && viewModel.user.frozen_until
                     ? "   解冻时间：" + Qt.formatDateTime(new Date(viewModel.user.frozen_until * 1000), "yyyy-MM-dd hh:mm")
                     : "")
            color: "#40535e"
        }

        GroupBox {
            title: "基本资料"
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 12
                    FormField { id: college; objectName: "profileCollege"; label: "学院"; maximumLength: 60 }
                    FormField { id: major; objectName: "profileMajor"; label: "专业"; maximumLength: 60 }
                    FormField { id: phone; objectName: "profilePhone"; label: "预留手机号"; maximumLength: 11 }
                }
                Button {
                    objectName: "profileSave"
                    text: "保存资料"
                    highlighted: true
                    enabled: !viewModel.busy
                    onClicked: viewModel.updateProfile({college: college.text, major: major.text, phone: phone.text})
                }
            }
        }

        GroupBox {
            title: "账号安全"
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                FormField {
                    id: currentPassword
                    objectName: "profileCurrentPassword"
                    label: "当前密码"
                    maximumLength: 32
                    echoMode: TextInput.Password
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 12
                    FormField { id: newPassword; objectName: "profileNewPassword"; label: "新密码"; maximumLength: 32; echoMode: TextInput.Password }
                    FormField { id: confirm; objectName: "profileConfirmPassword"; label: "确认新密码"; maximumLength: 32; echoMode: TextInput.Password }
                }
                RowLayout {
                    Button {
                        objectName: "profileChangePassword"
                        text: "修改密码"
                        enabled: !viewModel.busy && currentPassword.text.length > 0
                        onClicked: viewModel.changePassword(currentPassword.text, newPassword.text, confirm.text)
                    }
                    Button {
                        text: "生成新的恢复码"
                        enabled: !viewModel.busy && currentPassword.text.length > 0
                        onClicked: viewModel.renewRecoveryCode(currentPassword.text)
                    }
                }
            }
        }
    }
}
