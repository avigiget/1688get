# 1688get - 1688 商品下载技能

[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-blue)](https://openclaw.ai)

一个 OpenClaw Agent Skill，用于自动化下载 1688.com 商品页面的完整信息。

## 功能

- 下载主图（5张高清图）
- 下载详情页图片（全部）
- 提取商品标题、价格、规格参数
- 获取包装信息（重量、尺寸）
- 自动生成 Shopify 导入 CSV（英文版，含所有变体）

## 安装

```bash
# 克隆到 OpenClaw skills 目录
git clone https://github.com/avigiget/1688get.git ~/.openclaw/skills/1688get
```

## 依赖

- Chrome 浏览器（开启 CDP 调试模式，端口 9222）
- Playwright MCP 已配置
- curl

### 配置 Chrome CDP

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# Windows
chrome.exe --remote-debugging-port=9222
```

### 配置 Playwright MCP

`~/.openclaw/config/mcporter.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@executeautomation/playwright-mcp-server"]
    }
  }
}
```

## 使用

### 在 OpenClaw 中

直接告诉 Agent：
```
下载 1688 商品 https://detail.1688.com/offer/xxxxxx.html
```

### 手动执行

```bash
# 1. 确保 Chrome 在 9222 端口运行
# 2. 导航到商品页面
mcporter call playwright_navigate url="https://detail.1688.com/offer/xxxxxx.html" headless=false

# 3. 执行下载脚本
cd ~/.openclaw/skills/1688get
./scripts/download-1688.sh xxxxxx
```

## 输出结构

```
product_[ID]/
├── img1.jpg - img5.jpg          # 主图（5张）
├── detail_images/               # 详情图
│   ├── detail_01.jpg
│   └── ...
├── info.txt                     # 商品信息（中文）
└── shopify_import.csv           # Shopify 导入文件（英文）
```

## 注意事项

- 需要登录 1688 账号才能下载部分详情图
- 详情图是懒加载的，需要滚动页面
- 图片 URL 包含 `?__r__=` 时间戳参数，那是高清图链接
- 适当添加延迟避免被封

## 颜色尺码对照

| 中文 | 英文 |
|------|------|
| 红色/豆沙 | Red / Bean Paste |
| 黑色 | Black |
| 蓝色 | Blue |
| 米色/杏色 | Beige / Apricot |
| 灰色 | Gray |
| 白色 | White |
| 粉色 | Pink |
| 黄色 | Yellow |

| 中国码 | 美码 |
|--------|------|
| 35 | US 5 |
| 36 | US 6 |
| 37 | US 6.5 |
| 38 | US 7.5 |
| 39 | US 8 |
| 40 | US 9 |
| 41 | US 10 |
| 42 | US 11 |
| 43 | US 12 |
| 44 | US 13 |

## License

MIT
