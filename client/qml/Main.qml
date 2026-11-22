import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 工作区导航壳：页面注册表驱动，按角色过滤侧栏入口。
// F01–F10 各页面对应独立 QML 文件；ready=false 的页面显示规划占位。
ApplicationWindow {
    id: window

    width: 1120
    height: 770
    minimumWidth: 860
    minimumHeight: 640
    visible: true
    title: "智约实验室设备预约系统"
    color: Theme.windowBackground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBody
    palette.highlight: Theme.primary

    readonly property bool admin: viewModel.user.role === "admin"
    readonly property var roleNames: ({student: "学生", teacher: "教师", admin: "管理员"})

    // 页面注册表：nav=false 表示不进侧栏（由业务页跳转进入）。
    // ready=false 表示模块尚未接入，展示规划占位；接入后在文件内实现并置 true。
    readonly property var pageRegistry: [
        { key: "home",               title: "首页",       page: "",    roles: ["student", "teacher", "admin"], ready: true },
        { key: "equipment",          title: "设备浏览",   page: "F03", roles: ["student", "teacher", "admin"], ready: false, module: "M02" },
        { key: "equipmentDetail",    title: "设备详情",   page: "F04", roles: ["student", "teacher", "admin"], ready: false, module: "M02", nav: false },
        { key: "reservationCreate",  title: "预约申请",   page: "F05", roles: ["student", "teacher", "admin"], ready: false, module: "M03", nav: false },
        { key: "myReservations",     title: "我的预约",   page: "F06", roles: ["student", "teacher", "admin"], ready: false, module: "M03" },
        { key: "notifications",      title: "消息中心",   page: "F08", roles: ["student", "teacher", "admin"], ready: false, module: "M05" },
        { key: "profile",            title: "个人中心",   page: "F02", roles: ["student", "teacher", "admin"], ready: true },
        { key: "approval",           title: "审批工作台", page: "F07", roles: ["admin"], ready: false, module: "M04" },
        { key: "admin",              title: "后台管理",   page: "F09", roles: ["admin"], ready: false, module: "M06" },
        { key: "stats",              title: "统计报表",   page: "F10", roles: ["admin"], ready: false, module: "M07" },
        { key: "roles",              title: "角色管理",   page: "",    roles: ["admin"], ready: true },
    ]

    property string page: "home"

    function pageEntry(key) {
        for (let i = 0; i < pageRegistry.length; ++i)
            if (pageRegistry[i].key === key)
                return pageRegistry[i]
        return pageRegistry[0]
    }

    function pageAllowed(key) {
        return pageRegistry.some(function (entry) {
            return entry.key === key && entry.roles.indexOf(viewModel.user.role) >= 0
        })
    }

    function navigate(key) {
        viewModel.clearMessage()
        if (key === "profile")
            viewModel.refreshProfile()
        window.page = key
    }

    readonly property var pageComponents: ({
        home: homeComponent,
        equipment: equipmentComponent,
        equipmentDetail: equipmentDetailComponent,
        reservationCreate: reservationCreateComponent,
        myReservations: myReservationsComponent,
        notifications: notificationsComponent,
        profile: profileComponent,
        approval: approvalComponent,
        admin: adminComponent,
        stats: statsComponent,
        roles: rolesComponent,
    })

    Loader {
        anchors.fill: parent
        sourceComponent: viewModel.loggedIn ? workspacePage : authPage
    }

    Connections {
        target: viewModel
        function onUserChanged() {
            if (!viewModel.loggedIn || !window.pageAllowed(window.page))
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

    Component { id: authPage; AuthPage {} }

    Component {
        id: workspacePage
        RowLayout {
            spacing: 0

            NavSidebar {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                registry: window.pageRegistry
                role: viewModel.user.role
                currentPage: window.page
                userName: viewModel.user.name || ""
                roleLabel: window.roleNames[viewModel.user.role] || ""
                busy: viewModel.busy
                onNavigate: function (key) { window.navigate(key) }
                onLogoutRequested: viewModel.logout()
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                InfoBanner {
                    Layout.leftMargin: 24
                    Layout.rightMargin: 24
                    Layout.topMargin: 14
                    visible: viewModel.message.length > 0
                    message: viewModel.message
                    error: viewModel.error
                }

                Loader {
                    id: contentLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 24
                    sourceComponent: window.pageComponents[window.page] || homeComponent
                }
            }
        }
    }

    Component { id: homeComponent; HomePage { onNavigate: function (key) { window.navigate(key) } } }
    Component { id: profileComponent; ProfilePage {} }
    Component { id: rolesComponent; RolePage {} }
    Component { id: equipmentComponent; EquipmentPage {} }
    Component { id: equipmentDetailComponent; EquipmentDetailPage {} }
    Component { id: reservationCreateComponent; ReservationCreatePage {} }
    Component { id: myReservationsComponent; MyReservationsPage {} }
    Component { id: approvalComponent; ApprovalPage {} }
    Component { id: notificationsComponent; NotificationPage {} }
    Component { id: adminComponent; AdminPage {} }
    Component { id: statsComponent; StatsPage {} }
}
