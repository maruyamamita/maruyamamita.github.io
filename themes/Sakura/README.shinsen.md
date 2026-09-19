# Shinsen 对 Sakura 主题做的改动

主题本体取自 [honjun/hexo-theme-sakura](https://github.com/honjun/hexo-theme-sakura)
（作者 Mashiro / Hojun，MIT）。上游是一个**完整的个人站**，不是干净的空白主题：
它把作者自己的账号、收款码、评论后端凭据、歌单、视频都写死在配置和布局里。
直接照搬上线，站点会顶着别人的身份和别人的收款码运行。下面是逐项改动，按「为什么改」分组。

## 1. 配置层（`_config.yml`）

| 项 | 上游 | 现在 | 原因 |
| --- | --- | --- | --- |
| `prefixName` / `siteName` | `さくら荘その` / `hojun` | `''` / `Shinsen` | 站名 |
| `url` | `https://sakura.hojun.cn` | `https://maruyamamita.github.io` | 站点地址 |
| `favicon` | `/images/favicon.ico` | 同左 | 主题自带，可直接用 |
| `avatar` | `/img/custom/avatar.jpg` | `/images/cover/(3).jpg.webp` | 上游头像不在仓库里、只在作者 CDN 上；主题又没有自带头像图，先拿自带封面占位 |
| `cdn` | `https://cdn.jsdelivr.net/gh/honjun/cdn@1.6` | `''` | 置空后 `theme.cdn + xxx` 的图片全部回落到本站本地资源 |
| `menus` | 7 个菜单，多数指向不存在的页面 | 首页 / 归档 / GitHub | 上游菜单项（番组、歌单、留言板、友人帐、赞赏、客户端…）依赖一堆没建的页面，点进去 404 |
| `bg` | 作者 CDN 上的 8 张图 | 主题自带的 `images/cover/*.webp` | 去掉外部图床依赖 |
| `startdash` | 作者 B 站 / 万事屋三张卡 | `[]` | 不渲染外链卡片 |
| `social` / `msocial` | 作者的微博、知乎、微信、QQ | `{}` | 原样上线等于把访问者引到别人账号 |
| `donate` | 作者的支付宝/微信收款码、PayPal | `{}` | **绝不能上线的项**：收的是作者的钱 |
| `movies` | 作者 CDN 上的 `Unbroken.mp4` | 空 | 背景视频 |
| `aplayer` | 作者网易云歌单 `2660651585` | `{}` | 见 §2 |
| `valine` / `v_appId` / `v_appKey` | `true` + 一对 LeanCloud 凭据 | `false` + 空 | **那对 key 是主题作者的 LeanCloud 应用**，不是我们的。开着等于把评论写进别人的数据库 |
| `waline` | `enable: false` | 同左 | 上游本来就是关的 |
| `siteBuildingTime` | `07/17/2018` | `09/19/2026` | 用于算「运行时长」 |

## 2. 布局层（4 个文件）

| 文件 | 改动 | 为什么必须改 |
| --- | --- | --- |
| `layout/_partial/aplayer.ejs` | 整体包进 `<% if (theme.aplayer && theme.aplayer.id) { %>` | 上游**无条件**渲染 `<meting-js>`，会把作者的网易云歌单+APlayer+MetingJS 挂到**每个页面**。配置置空也挡不住，因为 `<meting-js>` 标签照样输出 |
| `layout/_partial/footer.ejs` | ① Valine 的 `av-min.js` / `Valine.min.js` 两个 `<script>` 包进 `<% if (theme.valine) %>`；② `&copy 2018` → `&copy <%= date(new Date(),'yyyy') %> <%= theme.siteName %>`；③ `Hosted by Coding Pages` → `Hosted by GitHub Pages` | ①上游无条件加载 LeanCloud SDK；②年份写死且无站名；③托管方写错 |
| `source/js/sakura-app.js` | `Siren.VA()` 的守卫 `if (!valine)` → `if (mashiro_option.v_appId && !valine)` | 光挡住 SDK 不够：`Siren.VA()` 在页面加载时被无条件调用，`!valine` 对 `undefined` 恒真，会拿空 appId 去 `new Valine()` 初始化 LeanCloud |
| `layout/_widget/common-article.ejs` | ① 开头算出 `_author/_avatar/_authorLink/_authorAbout` 四个回落变量；② 赞赏浮层包进 `<% if (theme.donate && theme.donate.alipay && ...) %>` | ①上游直接读 `post.author`/`post.avatar`/`post.authorLink`/`post.authorAbout`，**这四个字段不在 Hexo 的 post schema 里**，文章没在前沿元数据声明就渲染成空串（页脚作者块 `href="" src="" alt=""`）；②不改的话空 `donate` 会渲染两个空 `src` 的收款图 |
| `layout/_partial/head.ejs` | `qq_api_url` / `qq_avatar_api_url` 从 `api.mashiro.top` 置空 | 评论区 QQ 头像查询打的是作者自建的第三方接口 |

## 3. 依赖

- 新增 `hexo-generator-json-content@4.2.3`（devDependency 记在站点 `package.json`）。
  主题的站内搜索 `_widget/search/insight.ejs` 把索引地址写死成 `url_for("content.json")`，
  而这个文件只有该生成器会产出 —— 不装的话搜索框点了没反应，且**不会报错**。
- 主题自带的 `package.json` 是复制粘贴的残留（`name: hexo-theme-jsimple`、依赖 hexo 0.x 渲染器），
  **没有改**，站点实际用的是站点根 `package.json` 里的渲染器。

## 4. 有意保留的东西

- **页脚的主题署名**：`Theme Sakura by Mashiro & Hojun` 链接保留。这是主题作者的署名，
  删掉不合适。它和上面那些「作者个人账号」不是一类东西。
- **主题作者 CDN 上的 5 张小图**：懒加载占位条、404 图、两个 preload svg、翻页箭头
  （`cdn.jsdelivr.net/gh/honjun/cdn@1.6/img/other/*`）。主题本地没有这些资源，
  实测 jsdelivr 可达（HTTP 200），先留着；介意的话可以把它们抓下来放进 `source/` 再改引用。
- **不蒜子访问计数**：主题在页脚和 `sakura-app.js` 里各加载一次
  `busuanzi.ibruce.info`。这是一个第三方计数服务，能用；要彻底去第三方依赖需要改这两处。
