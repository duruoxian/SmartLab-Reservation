import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F09 后台管理页 —— M06 规划（仅管理员）
// 覆盖 FR-601-1～FR-602-2。设备与实验室台账、账号启停、
// 字典维护与操作日志；当前已实现的用户查询与角色调整见「角色管理」。
PageShell {
    title: "后台管理"
    subtitle: "设备台账、实验室管理、账号启停与操作日志"
    badge: "M06 · 规划中"

    EmptyState {
        module: "M06"
        title: "后台管理"
        description: "设备与实验室台账、账号启停、字典维护与操作日志将在 M06 模块接入。"
        features: ["设备与实验室台账管理", "账号启用 / 禁用与会话撤销", "字典维护与操作日志检索"]
        note: "用户查询与角色调整已在「角色管理」页实现（M01 子集）。"
    }
}
