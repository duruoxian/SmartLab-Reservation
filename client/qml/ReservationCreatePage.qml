import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F05 预约申请页 —— M03 规划
// 覆盖 FR-301-1～FR-301-3、BR-01～BR-04。由设备详情页（F04）进入；
// 学生、教师、管理员按相同规则申请本人预约，管理员另通过工作台审批。
PageShell {
    title: "预约申请"
    subtitle: "选择日期与时段、填写用途并提交申请"
    badge: "M03 · 规划中"

    EmptyState {
        module: "M03"
        title: "预约申请"
        description: "预约申请、冲突检测与提交确认将在 M03 模块接入。"
        note: "时段粒度 30 分钟；自助取消须距开始至少 2 小时（见 BR-04）。"
    }
}
