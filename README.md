# 智约·软件工程实验室设备预约管理系统（SmartLab-Reservation）

软件项目管理课程小组项目（第9组 · 指导教师：彭顺顺）。

面向学生、教师和实验室管理员，设计提供实验室设备浏览、预约申请、审批、签到/归还、违约记录、统计报表和后台管理的 C/S 架构系统。当前代码已实现 M01 用户与权限模块，其余业务模块保留为后续开发范围。

## 小组成员

| 姓名 | 职责 |
| :--- | :--- |
| 杜若贤 | 客户端程序单元设计、项目协调 |
| 冯春霖 | 后端模块设计、数据库设计 |
| 陈奕帆 | 校对与评审 |
| 杨宗霖 | 校对与评审 |
| 梁钊睿 | 校对与评审 |

## 技术栈

- **客户端**：Windows 10/11，C++17、Qt 6、QML / Qt Quick；构建要求 CMake 3.22+、Qt 6.2+，当前链接 Quick、QuickControls2、Network。
- **后端**：Python 3.10+、FastAPI、SQLAlchemy、PyJWT；具体依赖以 `backend/requirements.txt` 为准。
- **数据库**：当前使用 SQLite 3；MySQL 8.0.16+ 全量设计脚本见 `backend/sql/smartlab_schema_mysql80.sql`，不表示已完成 MySQL 部署或全模块实现。
- **接口**：HTTP/JSON，受保护请求使用 `Authorization: Bearer <JWT>`；鉴权成功通过响应头 `X-SmartLab-Token` 滚动续签。

## 系统模块

| 模块 | 说明 | 当前状态 |
| :--- | :--- | :--- |
| M01 | 用户与权限 | 已有账号、资料、会话、恢复码和管理员角色管理实现 |
| M02 | 设备与实验室资源 | 设计阶段；客户端设备首页为占位入口 |
| M03 | 预约管理 | 设计阶段 |
| M04 | 审批与签到归还 | 设计阶段 |
| M05 | 消息通知 | 设计阶段 |
| M06 | 后台管理 | 设计阶段；现有账号查询、角色修改属于 M01 |
| M07 | 统计报表 | 设计阶段 |

当前 ORM 自动建表范围是 `t_user`、`t_dict`、`t_auth_session`、`t_operation_log` 四表。MySQL 脚本包含全系统十六张设计表；额外业务表不会由当前应用自动创建，`create_all` 也不代替数据库迁移。

## 项目目录

| 目录 | 内容 |
| --- | --- |
| [backend/](backend/) | FastAPI 后端源码、依赖、测试及全量 MySQL 设计脚本 |
| [client/](client/) | Qt/QML 桌面客户端 |
| [doc/project/](doc/project/) | 五份编号正式文档、详细设计 Markdown 与 UML 源文件 |
| [doc/guides/](doc/guides/) | [模块化开发流程与登录实施指南](doc/guides/智约系统模块化开发流程与登录实施指南.docx) |
| [doc/templates/](doc/templates/) | 课程文档模板 |
| [doc/reference/](doc/reference/) | [第 9 组选题草案](doc/reference/9组项目.md) |
| [doc/project/archive/](doc/project/archive/) | 修订前原稿与备份，不作为当前正式设计依据 |

### 正式文档

以下文档于 2026-11-22 依据代码基线 `50fc4c5` 同步修订。文内保留原始编制日期、课程范围和交付目标，并区分当前实现、设计方案与待验证目标。本轮文档修订不构成项目测试、性能或生产部署验收。

1. [项目管理概述](doc/project/1.项目管理概述-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx)
2. [需求说明书](doc/project/2.需求说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx)
3. [概要设计说明书](doc/project/3.概要设计说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx)
4. 详细设计说明书：[Word](doc/project/4.详细设计说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx) · [Markdown](doc/project/4.详细设计说明书-第9组-智约实验室设备预约系统.md)
5. [数据库设计说明书](doc/project/5.数据库设计说明书-第9组-杜若贤、冯春霖、陈奕帆、杨宗霖、梁钊睿.docx)

[整体 UML 源文件](doc/project/UML/智约系统整体UML.vsdx)作为既有设计资料保留。本轮未重绘，也未验证图形布局、连线与当前物理表结构一致。数据库页部分字段仍需同步，例如 `last_active_at` 与当前 `last_activity_at`；概念事件键与 `(event_id, recipient_id)` 物理唯一约束也需区分。当前实现以代码及正式文档的现状说明为准，MySQL 物理设计以 SQL 脚本为准。

## M01 本地运行

从仓库根目录执行：

```powershell
.\start-dev.ps1
```

脚本中的默认 Python、Qt 路径是开发者机器配置，不保证适用于每台电脑。可通过 `-Python`、`-QtRoot`、`-QtVersion`、`-MingwKit` 或 `-Port` 指定本机环境。脚本构建桌面程序并默认在 `127.0.0.1:8765` 启动 API；退出桌面程序后，本次启动的 API 会关闭。本地 SQLite 文件默认是 `backend/data/smartlab.sqlite3`。普通用户可在客户端注册学生或教师账号。

如需初始化管理员，执行 `.\start-dev.ps1 -CreateAdmin`，按提示设定密码和预留手机号。默认管理员工号是 `admin0001`。使用自定义工号时，在 `backend/` 中运行所用 Python 的 `-m app.seed_admin --user-no <工号>`。注册或初始化时会显示一次恢复码，请妥善保存。找回密码需要工号或学号、预留手机号和一次性恢复码；手机号不代表已完成短信验证。个人中心可用当前密码生成新恢复码。

单独构建客户端可运行 `.\start-dev.ps1 -BuildOnly`，产物在 `build/SmartLab.exe`。Windows Qt 构建使用临时英文路径，以兼容仓库处于中文目录的情况。

在其他机器上，将 `backend/requirements.txt` 安装到项目 Python 环境。调试后端时，从 `backend/` 运行 `python -m uvicorn app.main:app --host 127.0.0.1 --port 8765`。健康检查和接口文档分别位于 `/api/health` 和 `/docs`。安装 `backend/requirements-dev.txt` 后可在 `backend/` 运行 `python -m pytest -q`；仓库已有测试代码，不代表本轮已经执行或通过测试。

M01 个人中心展示当前违约次数和预约冻结状态，违约明细及自动处理闭环由后续 M04 提供。JWT 与服务端会话共同校验，默认空闲有效期为 30 分钟；当前没有独立 `/refresh` 接口或 `refresh_token`。默认 SQLite 开发进程使用临时 JWT 签名密钥，重启后需要重新登录。MySQL 联调通过 `SMARTLAB_DB_URL` 和至少 32 字节的 `SMARTLAB_JWT_SECRET` 配置；本项目未预设 MySQL 主机、库名或数据库账号。
