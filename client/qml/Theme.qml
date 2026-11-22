pragma Singleton
import QtQuick

// 智约客户端统一视觉令牌。
// 颜色与字号沿用原浅色青绿风格；页面不得再写颜色字面量，统一引用本单例。
QtObject {
    // 背景 / 表面
    readonly property color windowBackground: "#edf3f5"
    readonly property color surface: "#ffffff"
    readonly property color surfaceBorder: "#d9e5e8"
    readonly property color surfaceHover: "#eef5f6"
    readonly property color disabledSurface: "#e3eced"

    // 侧栏与品牌
    readonly property color sidebar: "#13363c"
    readonly property color sidebarGradientTop: "#1b4d54"
    readonly property color sidebarGradientBottom: "#13363c"
    readonly property color sidebarMuted: "#b7d8d3"
    readonly property color sidebarBrand: "#d8eee9"

    // 主色
    readonly property color primary: "#13766a"
    readonly property color primaryHover: "#0f6a5f"
    readonly property color primaryPressed: "#0c5a51"
    readonly property color primaryFocus: "#12796e"
    readonly property color primaryChecked: "#12665d"

    // 文字
    readonly property color textPrimary: "#173440"
    readonly property color textSecondary: "#40535e"
    readonly property color textMuted: "#4a626d"
    readonly property color textFaint: "#526b76"
    readonly property color inputText: "#162e38"
    readonly property color inputPlaceholder: "#6b7f89"

    // 状态
    readonly property color successBackground: "#e4f4ec"
    readonly property color successForeground: "#176449"
    readonly property color dangerBackground: "#fff0ed"
    readonly property color dangerForeground: "#9f3c2f"
    readonly property color warningBackground: "#fdf5e6"
    readonly property color warningForeground: "#9a6a1f"
    readonly property color inputBorder: "#cad8de"
    readonly property color inputBorderHover: "#a3c2bc"

    // 表面
    readonly property color surfaceSunken: "#f3f7f8"
    readonly property color divider: "#e2eaed"

    // 形状与字体
    readonly property int radiusSmall: 5
    readonly property int radius: 7
    readonly property int radiusLarge: 12
    readonly property int radiusPanel: 14
    readonly property int fieldHeight: 43
    readonly property string fontFamily: "Microsoft YaHei UI"
    readonly property int fontBody: 14

    // 主色低透明度底色（用于徽标、选中态等），不引入新的字面量
    function tint(base, alpha) {
        return Qt.rgba(base.r, base.g, base.b, alpha)
    }
}
