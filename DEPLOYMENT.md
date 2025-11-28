# Nginx 部署指南

本项目现在支持通过 nginx + Node.js 进行部署，替代了原有的 Vercel Serverless 函数。

## 架构说明

- **前端**: React 应用，由 nginx 提供静态文件服务
- **后端**: Node.js Express 服务，运行在 3001 端口
- **代理**: nginx 将 `/api/*` 请求代理到后端服务

## 部署方式

### 方式一：Docker 部署（推荐）

1. **构建 Docker 镜像**
   ```bash
   npm run deploy:docker:build
   # 或者
   docker build -t proxy-provider-converter .
   ```

2. **运行容器**
   ```bash
   npm run deploy:docker:run
   # 或者
   docker run -p 48066:80 -p 43001:3001 proxy-provider-converter
   ```

3. **访问应用**
   - 前端：http://localhost
   - API：http://localhost/api/convert?url=xxx&target=clash
   - 健康检查：http://localhost/api/health

### 方式二：传统部署

#### 1. 安装依赖

```bash
# 安装前端依赖
npm install

# 安装后端依赖
npm install express cors
```

#### 2. 构建前端

```bash
npm run build
```

#### 3. 启动后端服务

```bash
# 开发模式（自动重启）
npm run server:dev

# 生产模式
npm run server
```

#### 4. 配置 nginx

将项目中的 `nginx.conf` 复制到 nginx 配置目录（通常是 `/etc/nginx/sites-available/` 或 `/etc/nginx/conf.d/`）：

```bash
sudo cp nginx.conf /etc/nginx/conf.d/proxy-provider-converter.conf
sudo nginx -t  # 测试配置
sudo systemctl reload nginx
```

#### 5. 部署静态文件

将构建后的 `dist` 目录复制到 nginx 根目录：

```bash
sudo cp -r dist/* /usr/share/nginx/html/
sudo systemctl restart nginx
```

### 方式三：使用 PM2 管理后端进程

```bash
# 安装 PM2
npm install -g pm2

# 启动后端服务
pm2 start server/index.js --name "proxy-converter-api"

# 查看状态
pm2 status

# 查看日志
pm2 logs proxy-converter-api

# 重启服务
pm2 restart proxy-converter-api
```

## 环境变量

可以通过环境变量配置后端服务：

```bash
# 设置端口（默认 3001）
export PORT=3001

# 启动服务
npm run server
```

## 健康检查

后端服务提供健康检查端点：

```bash
curl http://localhost:3001/health
```

响应示例：
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## API 使用

API 路径保持不变，与原 Vercel 版本完全兼容：

```
GET /api/convert?url=<订阅链接>&target=<clash|surge>
```

示例：
```bash
curl "http://localhost/api/convert?url=https://example.com/subscription&target=clash"
```

## 故障排查

### 1. 检查后端服务状态
```bash
curl http://localhost:3001/health
```

### 2. 检查 nginx 配置
```bash
nginx -t
```

### 3. 查看 nginx 日志
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 4. 查看后端服务日志
如果使用 PM2：
```bash
pm2 logs proxy-converter-api
```

如果直接运行：
```bash
npm run server
```

## 性能优化

1. **前端缓存**：nginx 配置已包含静态资源缓存策略
2. **Gzip 压缩**：已启用，减少传输大小
3. **安全头**：已配置基本的安全 HTTP 头

## 从 Vercel 迁移的变更

1. ✅ **API 兼容性**：完全保持原有的 API 接口
2. ✅ **功能完整性**：所有转换功能保持不变
3. ✅ **前端代码**：无需修改，自动适配
4. ✅ **部署灵活性**：支持多种部署方式
5. ✅ **性能提升**：本地部署，减少网络延迟

## 注意事项

- 确保 Node.js 版本 >= 18
- 后端服务默认运行在 3001 端口，可在 nginx 配置中修改
- 前端构建文件需要正确部署到 nginx 静态文件目录
- 如需修改 API 路径，请同步更新 nginx 配置和前端代码