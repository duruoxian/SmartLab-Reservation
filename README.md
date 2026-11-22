# 智约·软件工程实验室设备预约管理系统（SmartLab-Reservation）

软件项目管理课程小组项目（第9组 · 指导教师：彭顺顺）。

面向学生、教师和实验室管理员，提供实验室设备浏览、预约申请、审批、签到/归还、违约记录、统计报表和后台管理的 C/S 架构系统。

## 小组成员

| 姓名 | 职责 |
| :--- | :--- |
| 杜若贤 | 客户端程序单元设计、项目协调 |
| 冯春霖 | 后端模块设计、数据库设计 |
| 陈奕帆 | 校对与评审 |
| 杨宗霖 | 校对与评审 |
| 梁钊睿 | 校对与评审 |

## 技术栈

- **客户端**：Windows 10/11 桌面客户端（Qt 6 / QML）
- **后端**：Python 3.10+ / FastAPI
- **数据库**：MySQL 8.0 / SQLite 3
- **接口**：RESTful（HTTP/JSON，JWT 鉴权）

## 系统模块

| 模块 | 说明 |
| :--- | :--- |
| M01 | 用户与权限 |
| M02 | 设备与实验室资源 |
| M03 | 预约管理 |
| M04 | 审批与签到归还 |
| M05 | 消息通知 |
| M06 | 后台管理 |
| M07 | 统计报表 |

## 项目目录

| 目录 | 内容 |
| --- | --- |
| [backend/](backend/) | FastAPI 后端源码 |
| [client/](client/) | Qt/QML 桌面客户端 |
| [doc/project/](doc/project/) | 第 9 组的项目管理、需求和设计文档 |
| [doc/guides/](doc/guides/) | [模块化开发流程与登录实施指南](doc/guides/智约系统模块化开发流程与登录实施指南.docx) |
| [doc/templates/](doc/templates/) | 课程文档模板 |
| [doc/reference/](doc/reference/) | [第 9 组选题草案](doc/reference/9组项目.md) |

### 正式文档

- [项目管理概述](doc/project/项目管理概述-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx)
- [需求说明书](doc/project/需求说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx) v1.0（2026-10-25）
- [概要设计说明书](doc/project/概要设计说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx) v1.0（2026-10-25）
- 详细设计说明书（2026-11-21） [Word](doc/project/智约实验室设备预约系统-详细设计说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx) · [Markdown](doc/project/详细设计说明书-第9组-智约实验室设备预约系统.md)

## M01 本地运行

在当前 Windows 电脑上，从仓库根目录执行以下命令。

```powershell
.\start-dev.ps1
```

脚本使用智约专用 Python 和已安装的 Qt MinGW 套件，构建桌面程序并在 `127.0.0.1:8765` 启动 API。退出桌面程序后，本次启动的 API 会关闭。本地 SQLite 文件会自动建立在 `backend/data/`。普通用户可在客户端注册学生或教师账号。

如需初始化管理员，执行 `.\start-dev.ps1 -CreateAdmin`，按提示设定密码和预留手机号。默认管理员工号是 `admin0001`。使用自定义工号时，在 `backend/` 中运行所用 Python 的 `-m app.seed_admin --user-no <工号>`。注册或初始化时会显示一次恢复码，请妥善保存。找回密码时填入工号或学号、预留手机号和一次性恢复码。个人中心可用当前密码生成新恢复码。

单独构建客户端可运行 `.\start-dev.ps1 -BuildOnly`，产物在 `build/SmartLab.exe`。可通过 `-Python`、`-QtRoot`、`-QtVersion`、`-MingwKit` 或 `-Port` 指定本机环境。Windows Qt 构建使用临时英文路径，以兼容仓库处于中文目录的情况。

在其他机器上，将 `backend/requirements.txt` 安装到项目 Python 环境。调试后端时，从 `backend/` 运行 `python -m uvicorn app.main:app --host 127.0.0.1 --port 8765`。健康检查和接口文档分别位于 `/api/health` 和 `/docs`。安装 `backend/requirements-dev.txt` 后可在 `backend/` 运行 `python -m pytest -q`。

M01 已接入账号、个人资料、会话和角色管理。个人中心展示当前违约次数和预约冻结状态，违约明细由后续 M04 提供。默认 SQLite 开发进程使用临时 JWT 签名密钥，重启后需要重新登录。MySQL 联调通过 `SMARTLAB_DB_URL` 和至少 32 字节的 `SMARTLAB_JWT_SECRET` 配置。
