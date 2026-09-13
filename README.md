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

## 软件包策略（官方优先自动去重）
- 编译时由 `scripts/common/package-sync.sh` 从 kenzok8/small-package 导入 **153 个真第三方包**（16 个功能分类：代理、DNS、组网、NAS、Docker、媒体、iStore 生态等）。
- 逐包实时对照官方源码树与全部 feeds：**官方已有的一律使用官方版本**（原清单中 85 个重复包、88 个已失效包已清理）。
- 增删白名单：编辑 `scripts/common/package-sync.sh` 中的 `WHITELIST` 段（每行一个包名，`# ---------- xxx ----------` 为分类注释）。

## 功能开关（workflow 默认值）
- Docker 集成：关（`config/docker.config`）
- keepalived 主从路由：开（`config/keepalived.config`，含 luci-app-keepalived-ha）
- OpenClash：开（官方 feed 版，`config/openclash.config` 注入依赖）

## 提示
- 刷机有风险！请确认固件与设备匹配，并提前备份原厂固件。
- 改动 `repo_branch` / `config_file` 默认选项可能导致跨版本配置混用，非必要请保持默认。
