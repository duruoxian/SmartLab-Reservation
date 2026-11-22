import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F06 我的预约页 —— M03 规划
// 覆盖 FR-302-1～FR-302-2。展示本人预约记录与状态，
// 提供自助取消入口；签到与归还操作也在本页完成（M04 接入）。
PageShell {
    title: "我的预约"
    subtitle: "本人预约记录、状态跟踪与取消"
    badge: "M03 · 规划中"

    EmptyState {
        module: "M03"
        title: "我的预约"
        description: "本人预约记录、状态跟踪与自助取消将在 M03 模块接入。"
        features: ["本人预约列表与状态跟踪", "距开始 2 小时以上可自助取消", "签到与归还操作入口"]
        note: "签到与归还操作随 M04 审批与签到归还模块接入。"
    }
}
