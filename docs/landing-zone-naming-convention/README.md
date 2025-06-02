# 企业级Landing Zone命名规范

> 一套经过实践验证的云资源命名标准，适用于大型企业的Landing Zone架构

## 概述

本规范基于真实的企业级项目经验制定，平衡了技术最佳实践与业务实际需求，确保命名的一致性、可扩展性和工具兼容性。

## 核心原则

- **一致性**: 跨环境、跨资源类型的统一命名
- **可读性**: 自解释的命名，无需额外文档
- **兼容性**: 支持主流DevOps工具链
- **可扩展性**: 支持未来业务增长和技术演进

## 命名结构

### VPC命名格式
```
{prefix}-{company}-{project}-{zone}-{environment}-vpc{sequence}
```

### 子网命名格式

#### 基础格式
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}subnet{sequence}
```

#### 高可用扩展格式（推荐）
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}-{az}-subnet{sequence}
```

### 可用区标识符（可选）

当需要明确区分不同可用区的资源时，推荐使用以下格式：

| 可用区标识 | 说明 |
|-----------|------|
| `3a` | 可用区A（如ap-southeast-3a） |
| `3b` | 可用区B（如ap-southeast-3b） |
| `3c` | 可用区C（如ap-southeast-3c） |

**使用场景**：
- 多可用区高可用部署
- 跨可用区的网络规划
- 容灾和故障隔离需求

### 分隔符规则
- **连字符 (`-`)**: 主要分隔符，用于名称内部
- **下划线 (`_`)**: VPC标识符与子网名称的分隔符
- **避免冒号 (`:`)**: 为确保DevOps工具兼容性

## 组件定义

### 前缀 (Prefix)
按账户功能分类的标识符：

| 前缀 | 用途 |
|------|------|
| `network` | 核心网络和连接服务 |
| `security` | 安全工具和监控基础设施 |
| `devops` | CI/CD、开发和运维工具 |
| `log` | 日志和审计服务 |

### 功能区域 (Zone)
Landing Zone内的功能划分：

| 区域 | 用途 |
|------|------|
| `dmz` | 非军事化区域，面向公网的服务 |
| `acc` | 访问控制和连接服务 |
| `sec` | 安全运维和监控 |
| `sha` | 安全中心和分析 |
| `cbh` | 云堡垒机服务 |
| `devop` | 开发运维服务 |

### 环境 (Environment)
部署阶段标识符：

| 环境 | 用途 |
|------|------|
| `dev` | 开发环境 |
| `nprd` | 非生产环境（测试/预发布） |
| `prd` | 生产环境 |

### 服务缩写

| 服务 | 缩写 | 全称 |
|------|------|------|
| API网关 | `apig` | API Gateway |
| 网络地址转换 | `nat` | NAT Gateway |
| 弹性负载均衡 | `elb` | Elastic Load Balancer |
| 虚拟专用网络 | `vpn` | VPN Gateway |
| 专线连接 | `dc` | Direct Connect |
| 域名系统 | `dns` | DNS Services |
| 安全信息事件管理 | `siem` | SIEM Platform |
| 防火墙 | `fal` | Firewall Services |
| 安全中心 | `sha` | Security Analytics Hub |
| 云堡垒机 | `cbh` | Cloud Bastion Host |
| 开发运维 | `devop` | Development Operations |
| 企业路由器 | `er` | Enterprise Router |
| 云防火墙 | `cfw` | Cloud Firewall |
| VPN网关 | `vpngw` | VPN Gateway Service |
| 客户网关 | `vpncgw` | VPN Customer Gateway |
| 资源访问管理 | `ram` | Resource Access Manager |
| 安全管家 | `secmaster` | Security Master Service |
| 对象存储 | `obs` | Object Storage Service |

### 子网类型

| 类型 | 用途 |
|------|------|
| `public` | 面向互联网的子网 |
| `private` | 内部专用子网 |

### 编号规则

- **1-99**: 无需补零 (`1`, `2`, `99`)
- **100-999**: 自然三位数 (`100`, `101`, `999`)
- **1000+**: 四位数扩展 (`1000`, `1001`)

## 扩展命名格式

### 网络服务

#### 企业路由器 (ER)
```
# ER实例
{prefix}-{company}-{project}-{environment}-er{sequence}

# ER连接
{prefix}-er-attach-{resource-type}-{environment}-{sequence}

# ER路由表
rtb-{prefix}-{direction}-{environment}-{sequence}
```

#### 云防火墙 (CFW)
```
{prefix}-{company}-{project}-{environment}-cfw{sequence}
```

#### VPN服务
```
# VPN网关
{prefix}-{company}-{project}-{environment}-vpngw{sequence}

# VPN客户网关
{prefix}-{company}-{project}-{environment}-vpncgw{sequence}

# VPN连接
{prefix}-{company}-{project}-{environment}-vpn-connection{sequence}

# VPN弹性IP
{prefix}-{company}-{project}-{environment}-vpngw-eip{sequence}
```

#### NAT网关
```
{prefix}-{company}-{project}-{environment}-nat{sequence}
```

### 安全服务

#### 安全管家
```
{prefix}-{company}-{project}-secmaster{sequence}
```

#### 云堡垒机
```
{prefix}-{company}-{project}-cbh{sequence}
```

### 存储服务

#### 对象存储服务 (OBS)
```
{prefix}-{company}-{project}-{purpose}-{environment}-{sequence}
```

### 共享服务

#### 资源访问管理 (RAM)
```
{prefix}-{company}-{project}-{environment}-er-instance-share{sequence}
```

## 示例

### VPC和子网示例

#### 基础命名（单可用区部署）
```
# 网络账户 - DMZ开发环境
VPC:    network-company-project-dmz-dev-vpc1
子网:   company-project-dmz-dev-vpc1_apig-publicsubnet1
子网:   company-project-dmz-dev-vpc1_nat-publicsubnet1
子网:   company-project-dmz-dev-vpc1_elb-publicsubnet1
```

#### 高可用命名（多可用区部署）
```
# 网络账户 - DMZ生产环境（跨可用区）
VPC:    network-company-project-dmz-prd-vpc1
子网:   company-project-dmz-prd-vpc1_apig-public-3a-subnet1
子网:   company-project-dmz-prd-vpc1_apig-public-3b-subnet1
子网:   company-project-dmz-prd-vpc1_nat-public-3a-subnet1
子网:   company-project-dmz-prd-vpc1_elb-public-3a-subnet1
子网:   company-project-dmz-prd-vpc1_elb-public-3b-subnet1
```

#### 其他账户示例
```
# 安全账户 - 生产安全运维
VPC:    security-company-project-sec-prd-vpc1  
子网:   company-project-sec-prd-vpc1_siem-privatesubnet1
子网:   company-project-sec-prd-vpc1_fal-privatesubnet1

# DevOps账户 - 非生产环境
VPC:    devops-company-project-devop-nprd-vpc1
子网:   company-project-devop-nprd-vpc1_devop-privatesubnet1
```

### 网络服务示例

```
# 企业路由器
实例:     network-company-project-dev-er1
连接:     network-er-attach-dmz-dev-vpc-1
路由表:   rtb-network-forwarder-dev-1 / rtb-network-back-dev-1

# 云防火墙
network-company-project-dev-cfw1

# VPN服务
网关:     network-company-project-dev-vpngw1
弹性IP:   network-company-project-dev-vpngw-eip1
客户网关: network-company-project-dev-vpncgw1
连接:     network-company-project-dev-vpn-connection1

# NAT网关
network-company-project-dev-nat1
```

### 安全服务示例

```
# 安全管家（多账户）
network-company-project-secmaster1
security-company-project-secmaster1

# 云堡垒机
security-company-project-cbh1
```

### 存储服务示例

```
# OBS存储桶
security-company-project-log-archive-bucket-dev-1
```

### 共享服务示例

```
# 资源访问管理
network-company-project-dev-er-instance-share1
```

## 扩展示例

### 多环境部署
```
# 开发环境
network-company-project-dev-er1
network-company-project-dev-vpngw1
security-company-project-log-archive-bucket-dev-1

# 生产环境
network-company-project-prd-er1
network-company-project-prd-vpngw1
security-company-project-log-archive-bucket-prd-1
```

### 环境内扩展
```
# 生产环境多个ER实例
network-company-project-prd-er1
network-company-project-prd-er2

# 多个VPN连接
network-company-project-prd-vpn-connection1
network-company-project-prd-vpn-connection2
```

## 验证规则

### 字符约束
- **允许字符**: `a-z`, `0-9`, `-`, `_`
- **大小写**: 仅小写
- **长度限制**: VPC名称 ≤ 64字符，子网名称 ≤ 64字符

### 正则表达式模式
```regex
# VPC模式（支持1-9999）
^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc([1-9][0-9]{0,3})$

# 子网模式（支持1-9999）
^[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc([1-9][0-9]{0,3})_[a-z]+-[a-z]+subnet([1-9][0-9]{0,3})$

# 服务资源模式（支持1-9999）
^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]+-([1-9][0-9]{0,3})$
```

## 设计权衡

### 可用区标识的选择

在企业级部署中，是否在子网命名中包含可用区标识是一个重要的设计决策：

#### 包含可用区标识的优势
- **高可用架构明确**：清晰显示资源的可用区分布
- **故障隔离可见**：便于理解和管理跨可用区的依赖关系
- **扩展性更好**：支持未来多可用区的扩展需求
- **运维友好**：便于监控和故障排查

#### 不包含可用区标识的考虑
- **简化初期部署**：适合单可用区的简单场景
- **减少学习成本**：降低团队的理解和使用门槛
- **避免过度设计**：在不需要高可用的场景中保持简洁

#### 建议原则
- **生产环境**：强烈推荐使用可用区标识
- **开发/测试环境**：可根据实际需求选择
- **未来规划**：考虑业务发展对高可用的需求

## 扩展指南
1. 创建有意义的3-5字符缩写
2. 添加到服务缩写表
3. 遵循现有命名模式

### 添加新区域
1. 使用描述性的3-4字符标识符
2. 在区域定义中记录用途
3. 保持与现有模式的一致性

### 添加新环境
1. 使用清晰、简短的环境名称
2. 更新环境定义表
3. 在所有资源中一致应用

## 实施说明

### 工具兼容性
- **Terraform**: 资源和变量命名完全兼容
- **Ansible**: YAML安全，无需转义
- **CLI工具**: 可直接使用，无需引号
- **API**: URL安全，无需编码

### 迁移策略
- **新资源**: 立即应用规范
- **现有资源**: 在维护窗口期分阶段迁移
- **文档**: 更新所有相关引用以使用新命名

## 贡献

欢迎提交Issue和Pull Request来改进此规范。请确保：

1. 变更有充分的理由和说明
2. 保持与现有模式的一致性
3. 更新相关示例和文档
4. 考虑向后兼容性影响

## 许可证

MIT License

---

**文档版本**: 1.0  
**最后更新**: 2025-05-26  
**下次审查**: 2025-11-26