import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// 统一分页条：绑定 page / hasMore / busy，响应 pageRequested(page) 换页。
RowLayout {
    id: bar

    property int page: 1
    property bool hasMore: false
    property bool busy: false
    signal pageRequested(int page)

    Layout.alignment: Qt.AlignRight
    spacing: 8

    AppButton {
        variant: "text"
        compact: true
        text: "上一页"
        enabled: !bar.busy && bar.page > 1
        onClicked: bar.pageRequested(bar.page - 1)
    }
    Label {
        text: "第 " + bar.page + " 页"
        textFormat: Text.PlainText
        color: Theme.textSecondary
        font.pixelSize: 13
    }
    AppButton {
        variant: "text"
        compact: true
        text: "下一页"
        enabled: !bar.busy && bar.hasMore
        onClicked: bar.pageRequested(bar.page + 1)
    }
}
