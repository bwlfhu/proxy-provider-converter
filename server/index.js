import express from 'express';
import { z } from 'zod';
import { convertFromSubscription } from '../dist/core/convert.js';

const app = express();
const PORT = process.env.PORT || 3001;

// 中间件
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS 设置
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// 查询参数验证 schema
const querySchema = z.object({
  url: z.string().url(),
  target: z.enum(["clash", "surge"]).default("clash"),
});

// API 路由
app.get('/convert', async (req, res) => {
  const parsed = querySchema.safeParse({
    url: req.query.url,
    target: req.query.target,
  });

  if (!parsed.success) {
    res.status(400).json({
      error: "Invalid query parameters",
      details: parsed.error.flatten(),
    });
    return;
  }

  const { url, target } = parsed.data;

  try {
    const result = await convertFromSubscription(url, target);
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.status(200).send(result);
  } catch (error) {
    console.error('转换错误:', error);
    res.status(500).send(`${error}`);
  }
});

// 健康检查端点
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 启动服务器
app.listen(PORT, () => {
  console.log(`服务器运行在端口 ${PORT}`);
  console.log(`API 端点: http://localhost:${PORT}/convert`);
  console.log(`健康检查: http://localhost:${PORT}/health`);
});

export default app;