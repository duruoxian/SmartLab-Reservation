import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartLab.ui

// F03 设备浏览与搜索页 —— M02 规划
// 覆盖 FR-201-1～FR-202-3。接入 EquipmentViewModel 与 resource 路由后，
// 将本文件占位内容替换为实验室导航、分类、关键词搜索与分页列表。
PageShell {
    title: "设备浏览"
    subtitle: "实验室导航、分类浏览、关键词搜索与分页"
    badge: "M02 · 规划中"

    EmptyState {
        module: "M02"
        title: "设备浏览"
        description: "设备列表、分类导航与搜索将在 M02 模块接入。"
        note: "覆盖 FR-201-1 ～ FR-202-3；详情页（F04）从本页进入。"
    }
}
