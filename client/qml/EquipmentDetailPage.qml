import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F04 设备详情页 —— M02 规划
// 覆盖 FR-201-3。由设备浏览页（F03）携带设备标识进入，
// 展示设备资料、维护状态与未来 14 天可预约时段日历。
PageShell {
    title: "设备详情"
    subtitle: "设备资料、状态与可预约时段日历"
    badge: "M02 · 规划中"

    EmptyState {
        module: "M02"
        title: "设备详情"
        description: "设备详情与未来 14 天可预约时段日历将在 M02 模块接入。"
        note: "由设备浏览页携带设备 ID 进入；预约申请入口在详情页提供。"
    }
}
