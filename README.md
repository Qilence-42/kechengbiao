# 课表 · KechengBiao

> 完全离线的原生 Android 课程表应用：导入教务系统导出的「教学安排表」，
> 自动解析课程、教师、周次与地点，并在本地管理多个学期。

[![Android CI](https://github.com/USERNAME/REPO/actions/workflows/android.yml/badge.svg)](../../actions/workflows/android.yml)
![minSdk](https://img.shields.io/badge/minSdk-26-3ddc84)
![targetSdk](https://img.shields.io/badge/targetSdk-35-3ddc84)
![Kotlin](https://img.shields.io/badge/Kotlin-2.0.21-7f52ff)
![Compose](https://img.shields.io/badge/Compose-BOM%202024.12-4285f4)
![License](https://img.shields.io/badge/license-MIT-blue)

<!-- 上传前请把上面 CI 徽章里的 USERNAME/REPO 换成实际的 GitHub 用户名与仓库名 -->

<img src="docs/icon-512.png" width="120" align="right" alt="应用图标" />

**不联网 · 不注册 · 不上传任何数据** —— 没有网络权限，没有遥测 SDK，
文件只在你主动选择时于本机解析。

---

## 目录

- [功能特性](#功能特性)
- [截图](#截图)
- [快速开始](#快速开始)
- [导入课表](#导入课表)
- [项目结构](#项目结构)
- [技术栈](#技术栈)
- [测试](#测试)
- [已知限制](#已知限制)
- [隐私与权限](#隐私与权限)
- [文档](#文档)
- [许可证](#许可证)

---

## 功能特性

### 课表

- **今日课表**：按时间列出当天全部课程，正在上的课高亮「进行中」；左右滑动切换**前一天 / 后一天**
- **周课表**：`节次 × 星期` 网格，一屏展示整周；**一个格子就是一节课**，
  一门课跨 N 节就是跨 N 行的连续色块；左右滑动平移翻页切换周次
- **跨节课程精准渲染**：`top = (起始节 - 1) × 节高`、`height = 持续节数 × 节高`
- 单双周角标、线上课程图标、今天所在列高亮

### 导入

- 支持教务系统导出的 **HTML 表格**（扩展名常伪装成 `.xls`），**自动识别 GBK / UTF-8 编码**
- 纯手写解析器，**不依赖 Apache POI**（体积与 Android 兼容性考虑）
- 周次、节次、星期、教学方式、地点**分别结构化存储**，不是一整段原始字符串
- 解析不确定的字段标记「待确认」并保留原文，**绝不静默写错数据**
- 导入预览可逐条修正；写入在单个数据库事务内完成，失败自动回滚

### 提醒（双保险）

| 方案 | 依赖 | 应用被杀后 |
| --- | --- | --- |
| **系统日历**（可选开启） | `CalendarProvider` | ✅ 由系统日历服务触发 |
| **应用内独立提醒**（可选开启） | `AlarmManager` + `setAlarmClock` | ✅ 由系统闹钟唤醒 |

- 每日维护闹钟让提醒窗口**自我续期**，长期不打开应用也不会断
- 首次开启「应用内独立提醒」会引导你完成通知 / 精确闹钟 / 忽略电池优化 / 自启动 / 悬浮窗设置
- 可自定义闹钟铃声（系统铃声选择器，含闹钟类铃声）与震动

### 其他

- 多学期管理，按开学日期自动计算当前教学周
- 课程冲突检测（周次集合求交集，单双周互补不算冲突）
- 完整深色模式（纯白正文 + 亮蓝强调色）
- 课程搜索筛选、CSV 导出、本地 JSON 备份与恢复
- 导入历史管理（单条删除 / 一键清空，不影响已导入课程）

---

## 截图

<!--
把截图放到 docs/screenshots/ 下，然后取消下面的注释。
建议至少三张：今日课表、周课表、我的。
-->

<!--
| 今日课表 | 课表 | 我的 |
| :---: | :---: | :---: |
| <img src="docs/screenshots/today.png" width="220"> | <img src="docs/screenshots/week.png" width="220"> | <img src="docs/screenshots/mine.png" width="220"> |
-->

> 界面结构与设计约定见 [`docs/design/README.md`](docs/design/README.md)。

---

## 快速开始

### 环境要求

| 组件 | 版本 |
| --- | --- |
| JDK | **17**（AGP 8.6.1 要求） |
| Gradle | 8.7（使用仓库自带 Wrapper，无需手动安装） |
| Android Gradle Plugin | 8.6.1 |
| Kotlin / KSP | 2.0.21 / 2.0.21-1.0.28 |
| Android SDK Platform | **Android 15（API 35）** |
| Android Build-Tools | 34.0.0 或更高 |

### 用 Android Studio

1. `git clone` 本仓库
2. `File → Open` 选择仓库根目录
3. 首次同步会自动下载依赖；`local.properties` 由 Android Studio 自动生成

### 用命令行

```bash
# 1. 告诉 Gradle 你的 Android SDK 在哪（二选一）
export ANDROID_HOME="$HOME/Android/Sdk"          # Linux / macOS
setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk"   # Windows

# 或者复制模板并填写
cp local.properties.example local.properties

# 2. 构建
./gradlew assembleDebug          # Debug APK
./gradlew assembleRelease        # Release APK（需自己配签名）
./gradlew testDebugUnitTest      # 单元测试
```

Windows 上也可以直接用 [`build.bat`](build.bat)，它会自动探测 JDK / SDK：

```bat
build.bat                :: 等价于 gradlew assembleDebug
build.bat test
```

构建产物：

- `app/build/outputs/apk/debug/app-debug.apk`
- `app/build/outputs/apk/release/app-release.apk`

> **发布 Release 前**请替换签名：在 `app/build.gradle.kts` 里新增
> `signingConfigs.release` 并指向你自己的密钥库，再把
> `buildTypes.release.signingConfig` 指向它。仓库里的 Release 使用的是
> Android 标准调试密钥，**只能本地安装，不能上架**。

### 常见构建问题

| 现象 | 原因与处理 |
| --- | --- |
| `Could not connect to Kotlin compile daemon` / `AccessDeniedException ...\kotlin\daemon` | 受限环境无法写用户临时目录。加 `-Pkotlin.compiler.execution.strategy=in-process` |
| `plugin classpath entry points to a non-existent location: ...\u8BFEu8868\...` | 项目路径含中文导致 KSP 增量缓存把路径写成转义。删除 `app/build` 后加 `-Pksp.incremental=false`，或把项目移到纯英文路径 |
| `Couldn't open current thread, error = 5` | 沙箱禁止文件监听，无害。加 `org.gradle.vfs.watch=false` |

---

## 导入课表

### 支持的格式

| 实际格式 | 常见扩展名 | 识别方式 |
| --- | --- | --- |
| HTML 表格 | `.xls` `.html` `.htm` | 文件内容特征（**不看扩展名**） |
| OOXML 工作簿 | `.xlsx` | 暂不支持 |
| 二进制 Excel | `.xls`（真二进制） | 暂不支持 |

> 教务系统「导出为 Excel」得到的 `.xls` 绝大多数是 **GBK 编码的 HTML 表格**，
> 这正是本项目针对的格式。应用按**内容**判断格式，不看扩展名。

### 目标文件结构

```
表 1  学生信息    学号 / 姓名 / 所在班级 / 课程门数 / 学分
表 2  课表矩阵    首行 = 星期一 … 星期日；之后每行 = 一个节次
                  每个课程单元格：
                      线性代数(工)
                      XXX
                      2-17[1-2]
                      三教3302(XXX校区)
表 3  课程清单    上课班级代码 / 课程 / 总学时 / 学分 / 任课教师 / 上课时间地点
```

应用只取**表 2**（含星期表头且最大的那张），避免重复导入。

### 样例文件

[`samples/教学安排表.xls`](samples/教学安排表.xls) 是一份可直接导入的样例（GBK 的 HTML 表格）。

> **已脱敏**：原始导出文件含真实学号 / 姓名 / 班级，仓库版本已替换为示例数据；
> 课程、教师、周次、地点等内容保持原样。

解析细节见 [`docs/解析器说明.md`](docs/解析器说明.md)，
真实解析输出见 [`docs/示例导入结果.md`](docs/示例导入结果.md)。

---

## 项目结构

```
.
├── app/
│   ├── src/main/java/com/example/kechengbiao/
│   │   ├── data/            Room 实体 / DAO / 仓储
│   │   ├── domain/
│   │   │   ├── model/       领域模型（周次、节次、地点…）
│   │   │   ├── parser/      文本解析：周次 / 节次 / 星期 / 地点 / 单元格
│   │   │   └── usecase/     冲突检测
│   │   ├── importer/        文件 → 表格 → 课程
│   │   ├── notification/    提醒：AlarmManager 调度、日历同步、全屏闹钟
│   │   ├── ui/              Compose 界面（今日 / 课表 / 我的 + 覆盖页）
│   │   └── util/            学期日历、作息时间、设置
│   ├── src/test/            单元测试（JVM，无需设备）
│   ├── src/androidTest/     仪器测试（需设备 / 模拟器）
│   └── schemas/             Room 导出的数据库 schema
├── docs/                    解析器说明、测试报告、示例输出、设计素材
├── samples/                 可导入的样例课表
├── tools/                   辅助脚本（图标生成、单元测试直跑）
├── gradle/                  Wrapper + 版本目录（libs.versions.toml）
└── .github/workflows/       CI（构建 + 单元测试）
```

**分层原则**：解析器与提醒逻辑不依赖 UI，可独立单元测试；
数据层通过 Room 事务保证导入要么全成功、要么全回滚。

---

## 技术栈

| 领域 | 选型 |
| --- | --- |
| 语言 | Kotlin 2.0.21 |
| UI | Jetpack Compose + Material 3（自定义线条风主题） |
| 状态 | ViewModel + StateFlow |
| 存储 | Room 2.6.1（KSP） |
| 导航 | 单 Activity + 自建状态导航（不引入 Navigation 组件） |
| 提醒 | `AlarmManager` / `CalendarProvider` |
| 依赖注入 | 手写 ServiceLocator（避免引入 DI 框架，减小体积） |
| 文件选择 | Storage Access Framework（`ACTION_OPEN_DOCUMENT`） |

依赖版本集中在 [`gradle/libs.versions.toml`](gradle/libs.versions.toml)。

---

## 测试

单元测试全部是**纯 JVM** 测试，不需要设备或模拟器：

```bash
./gradlew testDebugUnitTest
```

| 测试类 | 覆盖内容 |
| --- | --- |
| `WeekParserTest` | 周次写法：区间、列表、单双周、自定义、括号内周次 |
| `PeriodDayParserTest` | 节次范围/列表、超范围不丢弃、星期全变体、表头列映射 |
| `CourseScheduleParserTest` | 单元格 → 课程；教师/地点分离；线上/线下判定；同格多课 |
| `ConflictDetectorTest` | 冲突、单双周互补、周次不重叠、重复导入、超学期范围 |
| `RealTimetableImportTest` | 真实样例端到端：编码、选表、节次来源、容错 |
| `PeriodSettingsTest` | 作息时间序列化/解析互逆、逐节修改、缺失回退 |
| `SemesterCalendarTest` | 开学日期 → 周/日期换算、非法输入 |
| `GridGeometryTest` | 网格无缝性、跨节卡片上下边对齐 |
| `WeekRruleTest` | 周次 → 日历 RRULE 压缩 |
| `CalendarEventPlannerTest` | 事件生成、**时区换算**、日历账户打分 |

仪器测试（`app/src/androidTest/`）覆盖 Room 集成与 Compose 冒烟，
**需要设备或模拟器**：

```bash
./gradlew connectedDebugAndroidTest
```

详细结果与限制见 [`docs/测试报告.md`](docs/测试报告.md)。

在受限环境里 Gradle 测试 worker 可能无法启动，可用 `tools/run-tests.ps1`
直接以 JUnitCore 跑同一批测试：

```bash
./gradlew :app:exportTestClasspath
powershell -File tools/run-tests.ps1
```

---

## 已知限制

1. **只支持教务系统的 HTML「教学安排表」**。`.xlsx` 与真正的二进制 `.xls` 不支持，
   导入时会给出明确提示而非静默失败。
2. **教师识别依赖常见姓氏表**。遇到未收录的姓氏会标「教师待确认」，不会写错数据。
3. **单双周语义**固定为「单周 = 奇数周，双周 = 偶数周」；若学校约定相反，需在预览中修改。
4. **默认作息时间**为上课时间（12 节），可在「我的 → 作息时间」修改。
5. **系统日历同步**写入你的默认日历，事件备注带 `[KechengBiao-Sync-v2]` 标记；
   关闭同步或重新同步会先清理带标记的旧事件，不会触碰你自己的日程。
6. **国内 ROM 的后台限制**（MIUI / EMUI / ColorOS 等）仍可能拦截全屏闹钟；
   此时通知栏提醒通常仍可到达，系统日历方案不受影响。
7. **当前 Release APK 使用 Android 调试密钥签名**，仅供本地安装。

---

## 隐私与权限

应用**完全离线**运行，没有 `INTERNET` 权限。

| 权限 | 用途 | 何时申请 |
| --- | --- | --- |
| `POST_NOTIFICATIONS` | 上课提醒 | 开启提醒时（Android 13+） |
| `SCHEDULE_EXACT_ALARM` | 准时触发闹钟 | 开启提醒时（Android 12+，跳系统设置） |
| `RECEIVE_BOOT_COMPLETED` | 重启后恢复提醒 | 安装时 |
| `VIBRATE` | 闹钟震动 | 安装时 |
| `WAKE_LOCK` | 全屏闹钟点亮屏幕 | 安装时 |
| `USE_FULL_SCREEN_INTENT` | 锁屏全屏闹钟 | 安装时 |
| `READ_CALENDAR` / `WRITE_CALENDAR` | 同步课表到系统日历 | 仅在开启「同步到系统日历」时（可选） |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | 避免被省电策略冻结 | 仅在开启「应用内独立提醒」时（可选） |
| `SYSTEM_ALERT_WINDOW` | 强提醒弹窗 | 仅在用户主动开启时（可选） |

**不申请**存储、通讯录、位置、相机权限；不使用任何遥测、统计或广告 SDK。

---

## 文档

| 文档 | 内容 |
| --- | --- |
| [`docs/解析器说明.md`](docs/解析器说明.md) | 支持的写法、歧义处理、踩坑记录、未解决问题 |
| [`docs/测试报告.md`](docs/测试报告.md) | 实际执行的命令与结果、未执行的测试与原因 |
| [`docs/示例导入结果.md`](docs/示例导入结果.md) | 在样例文件上的真实解析输出 |
| [`docs/design/README.md`](docs/design/README.md) | 图标生成流程与界面设计约定 |

重新生成示例导入结果：

```bash
./gradlew :app:exportTestClasspath
java -cp "$(cat app/build/test-classpath.txt)" \
     com.example.kechengbiao.docs.DocsReportTool .
```

---

## 贡献

欢迎提 Issue 与 PR。提交前请确保：

1. `./gradlew testDebugUnitTest` 全部通过；
2. 新增解析规则时同步补充 `WeekParserTest` / `CourseScheduleParserTest` 用例；
3. 不要在代码或测试里提交真实学号、姓名、班级等个人信息。

---

## 许可证

[MIT](LICENSE)
