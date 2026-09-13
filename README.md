# ImmortalWrt-25.12 for CMCC RAX3000M (EMMC)

基于 GitHub Actions 在线编译 [ImmortalWrt 25.12](https://github.com/immortalwrt/immortalwrt/tree/openwrt-25.12)（官方稳定分支，内核 6.12，apk 包管理）固件，目标设备 `cmcc_rax3000m-emmc`。

## 出厂默认（编译时自动写入）
- **LAN IP：`172.16.7.1`**
- **设备主机名：`CMCC-RAX3000M`**
- 修改位置：`scripts/25.12/diy-part2.sh`（作用于 base-files 的 config_generate，幂等可重复执行）

## 使用方法
1. 将本仓库全部内容 fork 到你的 GitHub 仓库。
2. 进入仓库 **Actions** 页 → 选择 **ImmortalWrt-25.12** → **Run workflow**，保持默认选项（`openwrt-25.12` 分支 + `25.12.config`）。
3. 首次编译约 2-4 小时，成功后到 **Releases** 下载 `sysupgrade.itb`（常规升级）；需要底层刷机时开启"上传所有文件"获取 GPT/preloader/FIP/recovery 全量包。
4. 刷机有风险！具体刷写步骤参见完整版项目包内的 `files/刷机教程.md`。

## Release 产物说明
- **每次发布默认包含**（已重命名为 `cmcc_rax3000m_版本_日期_xxx`）：
  - `sysupgrade.itb` —— 日常升级用（系统内"备份与升级"刷入）
  - `initramfs-recovery.itb` —— U-Boot 救砖/恢复用（内存系统，不含配置）
- 勾选 **上传所有文件** 时额外包含：`emmc-gpt.bin`（eMMC GPT 分区表）及输出目录内 sha256sums、.manifest、config.buildinfo 等。
- 注意：preloader / bl2 / FIP 引导文件不在本 workflow 编译范围（官方源码树不产该设备此类产物），底层救砖所需引导文件见刷机教程。

## 软件包策略（官方优先自动去重）
- 编译时由 `scripts/common/package-sync.sh` 从 kenzok8/small-package 导入 **153 个真第三方包**（16 个功能分类：代理、DNS、组网、NAS、Docker、媒体、iStore 生态等）。
- 逐包实时对照官方源码树与全部 feeds：**官方已有的一律使用官方版本**（原清单中 85 个重复包、88 个已失效包已清理）。
- 增删白名单：编辑 `scripts/common/package-sync.sh` 中的 `WHITELIST` 段（每行一个包名，`# ---------- xxx ----------` 为分类注释）。

## 功能开关（workflow 默认值）
- Docker 集成：关（`config/docker.config`）
- keepalived 主从路由：关（`config/keepalived.config`，含 luci-app-keepalived-ha）
- OpenClash：开（官方 feed 版，`config/openclash.config` 注入依赖）

## 提示
- 刷机有风险！请确认固件与设备匹配，并提前备份原厂固件。
- 改动 `repo_branch` / `config_file` 默认选项可能导致跨版本配置混用，非必要请保持默认。

## 值守式固件升级（GitHub Releases 固定 URL，无需 ASU 服务器）

每次编译发布 Release 时会额外上传一组固定资产（文件名恒定，URL 永远指向最新构建）：

- `autoupdate-RAX3000M-25.12-version.txt`：构建指纹（RUN_ID）
- `autoupdate-RAX3000M-25.12-sysupgrade.itb`：最新 sysupgrade 镜像
- `autoupdate-RAX3000M-25.12-sysupgrade.itb.sha256`：镜像 sha256

固件内置 `rax-autoupdate` 脚本，cron 每日自动检查一次（默认只提醒不自动刷）：

    rax-autoupdate status     # 查看状态
    rax-autoupdate check      # 手动检查更新
    rax-autoupdate apply      # 下载 + sha256 校验 + 刷写（保留配置，自动重启）
    rax-autoupdate disable    # 停用每日自动检查

- 升级地址基于本仓库 `releases/latest/download/<固定文件名>`，fork 后无需改配置自动适配
- 新版本提醒写入系统日志；如需推送，配置 /etc/config/autoupdate 的 notify_url（ntfy/Bark 等 POST 文本接口）
- 全自动无人值守刷写默认关闭；确认风险后可置 auto_apply '1'
