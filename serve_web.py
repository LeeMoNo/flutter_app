#!/usr/bin/env python3
"""
Flutter Web 临时服务器
支持 CORS 和正确的 MIME 类型
"""

import http.server
import socketserver
import os
import sys
import mimetypes
from pathlib import Path

# 设置端口
PORT = 8001

# 获取构建目录
BUILD_DIR = Path(__file__).parent / "build" / "web"

# 如果不在正确目录，尝试从当前目录查找
if not BUILD_DIR.exists():
    BUILD_DIR = Path("build/web")
if not BUILD_DIR.exists():
    BUILD_DIR = Path("web")

if not BUILD_DIR.exists():
    print(f"错误: 找不到 web 构建目录")
    print(f"请确保在项目根目录运行此脚本")
    sys.exit(1)

os.chdir(BUILD_DIR)

class FlutterHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """自定义请求处理器，支持 Flutter Web 所需的 MIME 类型"""
    
    def end_headers(self):
        # 添加 CORS 头（如果需要跨域）
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # 缓存控制（开发环境禁用缓存）
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        
        super().end_headers()
    
    def guess_type(self, path):
        """重写 MIME 类型猜测，确保正确的文件类型"""
        # 直接使用 mimetypes 模块，避免版本兼容性问题
        # 确保 WASM 文件使用正确的 MIME 类型
        if path.endswith('.wasm'):
            return 'application/wasm', None
        
        # 确保 JS 文件使用正确的 MIME 类型
        if path.endswith('.js'):
            return 'application/javascript', None
        
        # 确保 JSON 文件使用正确的 MIME 类型
        if path.endswith('.json'):
            return 'application/json', None
        
        # 对于其他文件，使用 mimetypes 模块
        mimetype, encoding = mimetypes.guess_type(path)
        if mimetype is None:
            mimetype = 'application/octet-stream'
        
        return mimetype, encoding
    
    def log_message(self, format, *args):
        """自定义日志格式"""
        print(f"[{self.address_string()}] {format % args}")

def main():
    """启动服务器"""
    try:
        with socketserver.TCPServer(("", PORT), FlutterHTTPRequestHandler) as httpd:
            print("=" * 60)
            print(f"Flutter Web 服务器已启动")
            print(f"目录: {BUILD_DIR.absolute()}")
            print(f"地址: http://localhost:{PORT}")
            print(f"地址: http://127.0.0.1:{PORT}")
            print("=" * 60)
            print("按 Ctrl+C 停止服务器")
            print("=" * 60)
            
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n\n服务器已停止")
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"错误: 端口 {PORT} 已被占用")
            print(f"请使用其他端口或关闭占用该端口的程序")
        else:
            print(f"错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

