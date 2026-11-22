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

    // 深色渐变背景；前景色调白，保证侧栏内文字按钮（退出登录）的对比度
    gradient: Gradient {
        GradientStop { position: 0; color: Theme.sidebarGradientTop }
        GradientStop { position: 1; color: Theme.sidebarGradientBottom }
    }
    Material.foreground: "white"

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
        anchors.margins: 22
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                implicitWidth: 36
                implicitHeight: 36
                radius: 11
                color: Qt.rgba(1, 1, 1, 0.14)
                Label {
                    anchors.centerIn: parent
                    text: "智"
                    textFormat: Text.PlainText
                    color: "white"
                    font.pixelSize: 17
                    font.bold: true
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    text: "智约"
                    textFormat: Text.PlainText
                    color: "white"
                    font.pixelSize: 20
                    font.bold: true
                }
                Label {
                    text: "实验室设备预约系统"
                    textFormat: Text.PlainText
                    color: Theme.sidebarMuted
                    font.pixelSize: 11
                }
            }
        }

        Item { Layout.preferredHeight: 16 }

        Repeater {
            model: sidebar.navEntries
            delegate: SidebarItem {}
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                implicitWidth: 38
                implicitHeight: 38
                radius: 19
                color: Qt.rgba(1, 1, 1, 0.16)
                Label {
                    anchors.centerIn: parent
                    text: sidebar.userName.length > 0 ? sidebar.userName.charAt(0) : "?"
                    textFormat: Text.PlainText
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    Layout.fillWidth: true
                    text: sidebar.userName
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: sidebar.roleLabel
                    textFormat: Text.PlainText
                    color: Theme.sidebarMuted
                    font.pixelSize: 11
                }
            }
        }

        Button {
            objectName: "logoutButton"
            text: "退出登录"
            Layout.fillWidth: true
            implicitHeight: 38
            enabled: !sidebar.busy
            contentItem: Label {
                text: "退出登录"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                color: "white"
                font.pixelSize: 13
            }
            background: Rectangle {
                radius: Theme.radius
                color: sidebar.busy ? Qt.rgba(1, 1, 1, 0.06)
                                    : hover.containsMouse ? Qt.rgba(1, 1, 1, 0.18)
                                                          : Qt.rgba(1, 1, 1, 0.10)
                border.color: Qt.rgba(1, 1, 1, 0.22)
            }
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                enabled: !sidebar.busy
                cursorShape: Qt.PointingHandCursor
                onClicked: sidebar.logoutRequested()
            }
        }
    }
}
