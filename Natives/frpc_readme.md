# Frpc 联机功能说明

## 概述
本项目支持通过 frpc 进行内网穿透，实现 Minecraft 服务器的外网联机功能。

## 配置文件格式
目前支持 .ini 格式的 frpc 配置文件，示例如下：

```ini
[common]
server_addr = example.com
server_port = 7000

[minecraft]
type = tcp
local_ip = 127.0.0.1
local_port = 25565
remote_port = 0
```

## 添加 frpc 可执行文件
由于 frpc 可执行文件较大且平台相关，未包含在源码中。请按以下步骤添加：

1. 前往 [frp 官方发布页面](https://github.com/fatedier/frp/releases) 下载适用于 iOS 的 frpc 可执行文件
2. 将下载的 frpc 文件放置在项目的 `Natives/resources` 目录中
3. 确保文件具有可执行权限

## 使用方法
1. 在应用中进入 "联机 (Frpc)" 页面
2. 输入或导入 frpc 配置文件
3. 点击 "启动 Frpc" 按钮
4. 配置将自动保存，下次启动应用时会自动加载

## 功能特点
- 支持从设备导入配置文件
- 自动保存配置，防止丢失
- 配置验证，确保格式正确
- 实时监控 frpc 进程状态
- 异常处理和错误提示