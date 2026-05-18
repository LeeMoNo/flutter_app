# flutter_application_1

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## 打包web版
使用 tree-shake-icons 来只打包使用的图标：
指令：flutter build web --release --tree-shake-icons
flutter build web --release -O4 --tree-shake-icons
出错：flutter build web --release --web-renderer html
优化方案               体积变化
删除 CanvasKit        29MB → 8MB
服务器 Gzip           8MB → 3-4MB
服务器 Brotli         8MB → 2-3MB
代码分割 + 延迟加载     额外减少 20-30%
图片优化              视资源而定

##  查看体积大小
cd build/web
du -sh .
find . -type f -exec du -h {} + | sort -hr | head -20

推荐使用 HTML Renderer
删除CanvasKit

启动服务：python3 serve_web.py


Svelte/SvelteKit
