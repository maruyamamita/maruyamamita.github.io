# D260919-shinsen-pages / deploy.ps1
#
# 一键部署 Hexo 站点到 maruyamamita.github.io 的 gh-pages 分支。
#
# 为什么这样写：
#  1) 提交身份走 GIT_AUTHOR_* / GIT_COMMITTER_* 环境变量 —— hexo-deployer-git 在自己的
#     .deploy_git 里提交，per-repo 的 git config 管不到它；用环境变量则不动全局身份。
#  2) GIT_TERMINAL_PROMPT=0 —— 认证失败时立刻报错，而不是挂在那里等凭据弹窗。
#  3) 部署链路是 SSH（git@github-shinsen），因为本机到 github.com 的 HTTPS 实测
#     "能握手、传不动"（curl 拿到 200 但 10 秒没下完页面）。
#
# 用法：pwsh -File .\deploy.ps1        （或 .\deploy.ps1 若已允许脚本执行）

$ErrorActionPreference = 'Stop'
$proj = $PSScriptRoot
Set-Location $proj

$env:GIT_AUTHOR_NAME     = 'Shinsen'
$env:GIT_AUTHOR_EMAIL    = '331147506+maruyamamita@users.noreply.github.com'
$env:GIT_COMMITTER_NAME  = 'Shinsen'
$env:GIT_COMMITTER_EMAIL = '331147506+maruyamamita@users.noreply.github.com'
$env:GIT_TERMINAL_PROMPT = '0'

Write-Host '== 1/4 hexo clean ==' -ForegroundColor Cyan
& hexo clean
if ($LASTEXITCODE -ne 0) { throw "hexo clean 失败 rc=$LASTEXITCODE" }

Write-Host '== 2/4 hexo generate ==' -ForegroundColor Cyan
& hexo generate
if ($LASTEXITCODE -ne 0) { throw "hexo generate 失败 rc=$LASTEXITCODE" }

Write-Host '== 3/4 产物自检 ==' -ForegroundColor Cyan
$idx = Join-Path $proj 'public\index.html'
if (-not (Test-Path $idx)) { throw "没有生成 public\index.html —— 不要往下推" }
$files = (Get-ChildItem (Join-Path $proj 'public') -Recurse -File | Measure-Object).Count
Write-Host ("   public\index.html {0} B / 共 {1} 个文件" -f (Get-Item $idx).Length, $files)

Write-Host '== 4/4 hexo deploy -> gh-pages ==' -ForegroundColor Cyan
& hexo deploy
if ($LASTEXITCODE -ne 0) { throw "hexo deploy 失败 rc=$LASTEXITCODE" }

Write-Host '== 远端 gh-pages 末次提交（判据：作者必须是 Shinsen）==' -ForegroundColor Green
git -C (Join-Path $proj '.deploy_git') log -1 --format='%h | %an <%ae> | %ad | %s' --date=iso
Write-Host '== 站点地址 ==' -ForegroundColor Green
Write-Host '   https://maruyamamita.github.io/'
