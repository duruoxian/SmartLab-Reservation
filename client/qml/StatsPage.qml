import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F10 统计报表页 —— M07 规划（仅管理员）
// 覆盖 FR-701-1～FR-701-3。按日期、实验室、类别、设备维度
// 展示使用率、预约量、违约率和审批通过率，使用 Qt Charts。
PageShell {
    title: "统计报表"
    subtitle: "使用率、预约量、违约率与审批通过率"
    badge: "M07 · 规划中"

    EmptyState {
        module: "M07"
        title: "统计报表"
        description: "统计图表与 CSV/PNG 导出将在 M07 模块接入。"
        features: ["日期 / 实验室 / 类别 / 设备多维筛选", "Qt Charts 图表与明细表格", "CSV / PNG 导出"]
        note: "实现时需在构建配置中引入 Qt Charts 组件。"
    }
}
