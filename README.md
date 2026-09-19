# D260919-shinsen-pages —— 沈川的 GitHub Pages（Hexo）

把 Hexo 静态站自动部署到账号 `maruyamamita` 的用户主页 `https://maruyamamita.github.io/`。

## 主题

当前主题 = `themes/Sakura`，取自 [honjun/hexo-theme-sakura](https://github.com/honjun/hexo-theme-sakura)。

**注意：上游仓库不是主题本身，是作者自己的整站**（根下有 `scaffolds/ source/ themes/ _config.yml`）。
真正的主题在 `themes/Sakura/`，只有这一层被搬进了本目录。

上游把作者的个人账号、收款码、评论后端凭据、歌单、视频全写死在配置和布局里，
所以搬过来之后做了一轮「去作者化」，逐项记在 `themes/Sakura/README.shinsen.md`。
其中最要紧的两条：`donate`（他的收款码）与 `valine` 的那对 LeanCloud key（他的应用），
不是「不好看」的问题，是原样上线会把访问者的钱和评论送到别人那里去。

搜索框依赖 `content.json`，由 `hexo-generator-json-content` 产出；不装这个生成器，
搜索框点了没反应且**不报错**。

## 分支约定

| 分支 | 内容 | 谁写 |
| --- | --- | --- |
| `main` | Hexo 源码（本目录） | `git push` 源码时 |
| `gh-pages` | `hexo generate` 的产物 | `hexo deploy`（由 hexo-deployer-git 写） |

GitHub Pages 设置：**Source = Deploy from a branch → Branch = `gh-pages` → `/ (root)`**。

## 一条命令部署

```powershell
pwsh -File .\deploy.ps1
```

脚本做四件事：`hexo clean` → `hexo generate` → 自检 `public\index.html` 存在 → `hexo deploy`，
最后打印 `.deploy_git` 的末次提交（判据：作者必须是 `Shinsen`）。

## 身份与认证

- 提交身份由 `deploy.ps1` 用 `GIT_AUTHOR_*` / `GIT_COMMITTER_*` **环境变量**注入：
  `Shinsen <331147506+maruyamamita@users.noreply.github.com>`。
  不用 `git config`（deployer 在自己的 `.deploy_git` 里提交，per-repo config 管不到它），
  也**不改全局身份**（全局仍是 `hatuki`，属羽月自己）。
- 认证走 SSH，别名 `github-shinsen`（`~/.ssh/config`），密钥 `~/.ssh/id_ed25519_shinsen_np`。
  **别把 remote 改成 `https://github.com/...`** ——见下。

## 一个必须记住的网络事实（2026-09-19 实测）

本机到 `github.com:443` 的 HTTPS：**TCP 0.14 s 建连、`curl` 拿到 HTTP 200，但整页 10 s 没下完**。
后果是 `git clone https://github.com/...` 会在 ~21 s 后超时（`hexo init` 就撞上了，
靠内置副本兜住才成功）。而 **SSH（22 口）秒级可用**。

⇒ 所有 git 远端一律用 SSH；需要装东西走 npm registry（实测 4 s，正常）。

## 本机工具链

node v24.15.0 / npm 11.12.1 / git 2.39.2 / hexo-cli 4.3.2 / hexo 7.3.0 / hexo-deployer-git 4.x
