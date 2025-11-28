# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个代理提供商转换工具（Proxy Provider Converter），用于将 Clash/Surge 订阅转换成 Proxy Provider（Clash）或 External Group（Surge）格式。该工具是一个 React 单页应用，使用 Vite 构建，部署在 Vercel 上。

## 开发命令

### 核心脚本
- `npm run dev` - 启动开发服务器
- `npm run build` - 构建生产版本
- `npm run start` / `npm run preview` - 预览构建后的应用

### 依赖安装
- 使用 `npm install` 安装依赖
- 项目使用 pnpm 作为包管理器（推荐）

## 架构结构

### 前端架构
- **主应用**: `src/App.tsx` - React 主组件，处理用户界面和交互
- **转换核心**: `src/core/convert.ts` - 核心转换逻辑，支持 Clash/Surge 互转
- **样式**: 使用 Tailwind CSS 4.x，配置在 `vite.config.mjs`
- **图标**: Heroicons (@heroicons/react)

### 后端架构
- **API 端点**: `api/convert.ts` - Vercel Serverless 函数，处理转换请求
- **验证**: 使用 Zod 进行参数验证
- **格式**: 统一的中间格式实现 Clash <-> Surge 双向转换

### 项目文件结构
```
src/
├── App.tsx              # React 主应用组件
├── main.tsx            # React 入口文件
├── core/
│   └── convert.ts      # 核心转换逻辑
├── types/
│   └── zod.d.ts        # Zod 类型定义
└── styles/
    ├── global.css      # 全局样式
    └── index.css       # 入口样式

api/
└── convert.ts          # Vercel Serverless API

public/
└── logo.svg           # 应用图标
```

## 核心技术栈

### 前端
- **React 19.2** - 用户界面框架
- **TypeScript** - 类型安全
- **Tailwind CSS 4.x** - 样式框架
- **Vite 7.x** - 构建工具
- **Axios** - HTTP 请求库
- **YAML** - YAML 解析库
- **React Hot Toast** - 通知组件
- **React Copy to Clipboard** - 复制功能
- **Zod** - 运行时类型验证

### 转换逻辑详解

项目采用统一中间格式的设计模式，在 `src/core/convert.ts` 中实现：

1. **支持类型**: Shadowsocks、VMess、Trojan
2. **转换路径**:
   - Clash → Clash (Proxy Provider)
   - Surge → Surge (External Group)
   - Clash → Surge
   - Surge → Clash
3. **中间格式**: 统一的 Proxy 类型定义，便于不同格式间转换
4. **过滤规则**: 自动过滤不支持的协议和配置

### API 设计
- **端点**: `/api/convert`
- **查询参数**:
  - `url` (required): 订阅链接
  - `target` (optional): 转换目标 ("clash" 或 "surge"，默认 "clash")
- **User-Agent**: 模拟 ClashX Pro 客户端
- **响应格式**: 纯文本，直接返回转换结果

## 部署配置

- **平台**: Vercel
- **构建配置**: `vercel.json`
- **TypeScript**: `tsconfig.json` 包含 `src` 和 `api` 目录
- **输出目录**: `dist`

## 开发注意事项

1. **转换逻辑修改**: 核心转换逻辑集中在 `src/core/convert.ts`，支持协议的增删改
2. **UI 组件**: 主要在 `src/App.tsx` 中，使用 Tailwind CSS 类名
3. **API 验证**: 使用 Zod 进行严格的参数验证
4. **错误处理**: 统一的错误响应格式
5. **字符编码**: API 响应设置 UTF-8 编码确保中文正常显示

## 常见开发场景

### 添加新的代理协议支持
1. 在 `src/core/convert.ts` 的 `Proxy` 类型中添加新的协议类型
2. 更新 `clashProxyToIntermediate` 函数处理新协议
3. 更新 `intermediateToSurgeLine` 和 `intermediateToClashProxy` 函数
4. 更新 `surgeLineToIntermediate` 函数支持反向解析

### 修改 UI 界面
1. 主要修改 `src/App.tsx`
2. 样式使用 Tailwind CSS 类
3. 图标使用 @heroicons/react 组件

### API 功能扩展
1. 修改 `api/convert.ts` 中的 Zod 验证 schema
2. 更新 `src/core/convert.ts` 中的 `convertFromSubscription` 函数