# Claude Knowledge Vault

[English](README.md) | [中文](README_CN.md)

把 Claude Code 零散、隐藏的记忆文件，变成一个持久化、可搜索的知识库 -- 基于 Obsidian。

## 问题

每次 Claude Code 学到你的偏好、构建工具链、写作风格或项目上下文时，都会把它们存成记忆文件，散落在 `~/.claude/projects/*/memory/` 目录下。这些文件：

- **零散分布**在各个项目目录中，没有统一的视图
- **对你不可见** -- 没有内置的方式来浏览或搜索它们
- **与你的笔记工作流脱节**
- **被锁定在一台机器上**，无法跨设备访问

如果你在远程服务器上开发 -- GPU 集群、云端虚拟机、共享开发机 -- 问题就更严重了。你辛辛苦苦积累的知识留在了一台你不会随身携带的机器上，笔记本、手机或其他设备都无法访问。

你其实一直在积累一个很有价值的知识库，但你自己却用不上它。

## 解决方案

Claude Knowledge Vault 会持续把所有 Claude Code 记忆同步到一个 [Obsidian](https://obsidian.md/) 知识库中，你可以在里面浏览、搜索、关联和扩展它们。Claude 存储的每一条反馈偏好、项目决策和参考文档，都会变成你知识图谱中的一篇正式笔记。

**为远程工作流而生：** 如果你在远程服务器上开发，这个工具能帮你打通壁垒。服务器上的后台服务会把记忆聚合到知识库中，Syncthing 则自动实时同步到你的本地机器 -- 初始配置之后无需任何手动操作，也不用 SSH 隧道。知识跟着你走，而不是反过来。

```
Claude Code 会话
    -> 将记忆写入 ~/.claude/projects/*/memory/
            |
    同步服务（监听文件变更）
            |
            v
    ~/obsidian-vault/claude-memories/
            |
    Syncthing（可选，实时同步）
            |
            v
    你的笔记本 / 手机 / 平板上的 Obsidian
```

## 功能特性

- **自动同步** -- 后台服务监听新的记忆文件，按项目分类整理后复制到你的知识库中
- **远程到本地同步** -- 通过 Syncthing 无缝连接远程服务器和本地机器；知识实时送达你的笔记本，无需手动传输
- **斜杠命令** -- `/sync-knowledge` 强制同步并获取摘要；`/vault-note` 从任意 Claude 会话中保存笔记
- **Obsidian 仪表盘** -- 一个首页，通过 Dataview 查询展示所有项目的最近变更
- **多设备访问** -- 可选的 Syncthing 配置，实现到任意机器的实时双向同步
- **零锁定** -- 一切都是纯 Markdown，没有专有格式，不依赖云服务

## 快速开始

```bash
git clone https://github.com/crqu/claude-knowledge-vault.git
cd claude-knowledge-vault
./scripts/install.sh
```

安装程序会：
1. 询问你的知识库路径（默认：`~/obsidian-vault`）
2. 创建一个 Obsidian 就绪的知识库结构
3. 安装后台同步服务（Linux systemd）
4. 在 Claude Code 中注册 `/sync-knowledge` 和 `/vault-note` 命令
5. 对已有的记忆文件执行一次初始同步

## 斜杠命令

### `/sync-knowledge [topic]`

强制同步所有 Claude Code 记忆并获取按项目分类的摘要。传入一个主题可以跨所有已存储的知识进行搜索。

```
> /sync-knowledge

Synced memories from 3 project(s):

**web-app** (5 files)
  - User prefers Tailwind over styled-components
  - API rate limiting set to 100 req/min
  - Deploy pipeline uses GitHub Actions → AWS ECS

**ml-pipeline** (3 files)
  - Training uses A100 GPUs, batch size 256
  - Checkpoint format: dict with 'model_state_dict' key

**docs-site** (2 files)
  - Content uses MDX with custom components
```

### `/vault-note <content>`

从任意 Claude Code 会话中直接保存笔记到知识库：

```
> /vault-note Key finding: the RQE loss converges 2x faster with cosine warmup

Created: projects/ml-pipeline/rqe-loss-warmup-finding.md
```

## 多设备同步

想在笔记本、手机或平板上访问你的知识库？请查看 [docs/SYNC-GUIDE.md](docs/SYNC-GUIDE.md)，了解如何设置 Syncthing（免费，P2P）或其他同步方式（Git、rsync、iCloud、Obsidian Sync）。

## 工作原理

详见 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)，内容包括：
- Claude Code 的记忆格式和存储方式
- 同步管道
- 知识库结构
- 为什么 Obsidian 是天然的选择（兼容 Markdown + YAML frontmatter + wikilinks）

## 环境要求

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)（任何支持斜杠命令的版本）
- `rsync`（macOS 和大多数 Linux 发行版已预装）
- **可选：** [Obsidian](https://obsidian.md/) 用于浏览知识库
- **可选：** [Syncthing](https://syncthing.net/) 用于多设备同步
- **可选：** `inotify-tools` 用于 Linux 上的文件系统级监听（不可用时会回退到轮询）

## 卸载

```bash
./scripts/uninstall.sh
```

停止服务，移除命令和配置。删除知识库前会先征求你的确认（默认保留）。

## 许可证

MIT
