import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F08 消息中心页 —— M05 规划
// 覆盖 FR-501-1～FR-501-2。展示本人站内消息、
// 未读计数与已读管理；公告由管理员发布。
PageShell {
    title: "消息中心"
    subtitle: "站内消息、公告与已读管理"
    badge: "M05 · 规划中"

    EmptyState {
        module: "M05"
        title: "消息中心"
        description: "站内消息列表、未读计数与已读管理将在 M05 模块接入。"
        features: ["本人消息列表与未读计数", "单条 / 批量 / 全部已读", "管理员公告发布"]
        note: "后台轮询接入时不得延长登录会话（见详细设计 8.5 算法）。"
    }
}
