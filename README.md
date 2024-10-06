# 项目名称

REMOTE TOOL

用于研究学习PowerShell项目

## 项目功能

LogOutput 日志输出工具
XmlRead xml查询工具
PerformanceTest 性能测试
SimulationTest 模拟测试 (building...)

## 项目结构

- `X-drive\opt\Scripts\Common\` - 共通方法路径
- `X-drive\opt\Scripts\Log\` - 日志路径
- `X-drive\opt\Scripts\` - 脚本路径
- `Y-drive\opt\WorkSpace` - 工作目录，用于测试
- `TEST_TOOL` - 测试工具，包含 性能测试 和 模拟测试

## 环境要求

windows
PowerShell 5+

## 安装和构建

1. **克隆项目**

   ```sh
   git clone https://github.com/QQDDTT/PREMOTE_TOOL.git

2. **建立工作路径**

New-Item -Path "Projectpath/Y-drive/opt/WorkSpace" -ItemType Directory
