import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 工作区左侧导航：按角色过滤页面注册表，未接入模块显示"规划"角标。
Rectangle {
    id: sidebar

    // Main.qml 的页面注册表：[{key,title,page,roles,ready,module,nav}]
    property var registry: []
    property string role: ""
    property string currentPage: "home"
    property string userName: ""
    property string roleLabel: ""
    property bool busy: false

    signal navigate(string key)
    signal logoutRequested()

    readonly property var navEntries: registry.filter(function (entry) {
        return entry.nav !== false && entry.roles.indexOf(role) >= 0
    })

    color: Theme.sidebar

    component SidebarItem: Rectangle {
        id: item
        required property var modelData
        readonly property bool active: sidebar.currentPage === modelData.key

        Layout.fillWidth: true
        implicitHeight: 40
        radius: Theme.radius
        color: active ? Qt.rgba(1, 1, 1, 0.14)
                      : pointer.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        objectName: modelData.key + "Navigation"

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 18
            radius: 2
            visible: item.active
            color: Theme.sidebarMuted
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 10
            spacing: 8

            Label {
                Layout.fillWidth: true
                text: item.modelData.title
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: item.active ? "white" : Theme.sidebarMuted
                font.bold: item.active
            }
            Label {
                visible: !item.modelData.ready
                text: "规划"
                textFormat: Text.PlainText
                color: Theme.sidebarMuted
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            enabled: !sidebar.busy
            cursorShape: Qt.PointingHandCursor
            onClicked: sidebar.navigate(item.modelData.key)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 9

        Label {
            text: "智约"
            textFormat: Text.PlainText
            color: "white"
            font.pixelSize: 32
            font.bold: true
        }
        Label {
            text: "实验室设备预约系统"
            textFormat: Text.PlainText
            color: Theme.sidebarMuted
            font.pixelSize: 14
        }
        Item { Layout.preferredHeight: 24 }

        Repeater {
            model: sidebar.navEntries
            delegate: SidebarItem {}
        }

        Item { Layout.fillHeight: true }

        Label {
            Layout.fillWidth: true
            text: sidebar.userName
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: "white"
            font.bold: true
        }
        Label {
            text: sidebar.roleLabel
            textFormat: Text.PlainText
            color: Theme.sidebarMuted
        }
        Button {
            objectName: "logoutButton"
            text: "退出登录"
            Layout.fillWidth: true
            enabled: !sidebar.busy
            onClicked: sidebar.logoutRequested()
        }
    }
}
