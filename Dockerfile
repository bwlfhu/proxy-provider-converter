# 多阶段构建
FROM node:20-alpine AS builder

# 安装 pnpm
RUN npm install -g pnpm

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install

# 复制源代码
COPY . .

# 构建前端
RUN pnpm run build

# 生产阶段 - nginx + node
FROM node:20-alpine AS backend

# 安装 nginx 和 pnpm
RUN apk add --no-cache nginx && npm install -g pnpm

# 创建应用目录
WORKDIR /home/webbuild

# 复制 package.json 和 pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# 安装所有依赖（包括 TypeScript 用于编译）
RUN pnpm install

# 复制后端代码和转换核心代码
COPY server/ ./server/
COPY src/ ./src/
COPY tsconfig.json ./

# 编译 TypeScript
RUN pnpm run tsc

# 创建 nginx 运行目录
RUN mkdir -p /var/cache/nginx /var/log/nginx /var/run

# 从 builder 阶段复制构建好的前端文件
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 nginx 配置
COPY nginx.conf /etc/nginx/nginx.conf

# 创建启动脚本
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "启动 Node.js 后端服务..."' >> /start.sh && \
    echo 'cd /home/webbuild && node server/index.js &' >> /start.sh && \
    echo 'echo "启动 nginx 前端服务..."' >> /start.sh && \
    echo 'nginx -g "daemon off;"' >> /start.sh && \
    chmod +x /start.sh

# 暴露端口
EXPOSE 80 3001

# 启动服务
CMD ["/start.sh"]