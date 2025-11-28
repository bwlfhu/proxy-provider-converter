@echo off
echo 🚀 启动代理提供商转换器开发环境...

:: 检查是否安装了依赖
if not exist "node_modules" (
    echo 📦 安装依赖...
    npm install
)

:: 构建前端
echo 🔨 构建前端...
npm run build

:: 启动后端服务
echo 🔧 启动后端服务 (端口 3001)...
start "Backend Server" cmd /k "npm run server"

:: 等待后端启动
timeout /t 3 /nobreak >nul

:: 启动前端开发服务器
echo 🌐 启动前端开发服务器 (端口 5173)...
start "Frontend Dev Server" cmd /k "npm run dev"

echo ✅ 开发环境启动完成！
echo 📱 前端: http://localhost:5173
echo 🔌 API: http://localhost:3001/convert?url=xxx^&target=clash
echo 💚 健康检查: http://localhost:3001/health
echo.
echo 关闭此窗口不会停止服务，请手动关闭各个服务窗口
pause