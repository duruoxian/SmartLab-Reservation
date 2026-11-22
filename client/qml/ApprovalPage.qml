import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F07 审批工作台页 —— M04 规划（仅管理员）
// 覆盖 FR-401-1～FR-403-3。集中处理待审批预约、
// 签到归还异常与逾期实物归还确认。
PageShell {
    title: "审批工作台"
    subtitle: "待审批列表、批准与驳回、逾期归还确认"
    badge: "M04 · 规划中"

    EmptyState {
        module: "M04"
        title: "审批工作台"
        description: "待审批列表、批准/驳回与逾期归还确认将在 M04 模块接入。"
        features: ["待审批列表按申请时间排序", "批准 / 驳回，驳回必填意见", "逾期实物归还确认与解冻"]
        note: "仅管理员可见；待审批超过 2 个工作日自动提醒。"
    }
}
