/* 首页 banner：每次加载从下面这组图里随机取一张。
 *
 * 为什么需要这个文件：Butterfly 的 index_img 是静态的一张图，没有随机轮播；
 * 而 Sakura 时代羽月要的形态就是「每次加载随机取一张」。这里在 DOM 就绪后
 * 覆盖 #page-header 的内联背景，只对首页那张全屏 banner（.full_page）生效，
 * 文章页/归档页仍用配置里的 index_img / archive_img / default_top_img。
 *
 * 换图：改下面这个数组（图在 site 的 source/img/bg/ 下）。
 */
(function () {
  var IMGS = [
    '/img/bg/bg-01.jpg',
    '/img/bg/bg-02.jpg',
    '/img/bg/bg-03.jpg',
    '/img/bg/bg-04.jpg',
    '/img/bg/bg-05.jpg'
  ]

  function apply () {
    var header = document.getElementById('page-header')
    if (!header) return
    // 只在首页的全屏 banner 上换：Butterfly 给首页加的是 full_page
    if (!header.classList.contains('full_page')) return
    var pick = IMGS[Math.floor(Math.random() * IMGS.length)]
    header.style.backgroundImage = 'url("' + pick + '")'
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', apply)
  } else {
    apply()
  }
})();
