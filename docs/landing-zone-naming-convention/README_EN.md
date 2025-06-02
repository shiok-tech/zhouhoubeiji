# Enterprise Landing Zone Naming Convention

> A battle-tested cloud resource naming standard for large-scale enterprise Landing Zone architectures

## Overview

This naming convention is derived from real-world enterprise project experience, balancing technical best practices with business requirements to ensure consistency, scalability, and tool compatibility.

## Core Principles

- **Consistency**: Unified naming across environments and resource types
- **Readability**: Self-documenting names requiring no additional documentation
- **Compatibility**: Support for mainstream DevOps toolchains
- **Scalability**: Support for future business growth and technical evolution

## Naming Structure

### VPC Naming Format
```
{prefix}-{company}-{project}-{zone}-{environment}-vpc{sequence}
```

### Subnet Naming Format

#### Basic Format
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}subnet{sequence}
```

#### High Availability Extended Format (Recommended)
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}-{az}-subnet{sequence}
```

### Availability Zone Identifiers (Optional)

When explicit differentiation of resources across availability zones is required, use the following format:

| AZ Identifier | Description |
|---------------|-------------|
| `3a` | Availability Zone A (e.g., ap-southeast-3a) |
| `3b` | Availability Zone B (e.g., ap-southeast-3b) |
| `3c` | Availability Zone C (e.g., ap-southeast-3c) |

**Use Cases**:
- Multi-AZ high availability deployments
- Cross-AZ network planning
- Disaster recovery and fault isolation requirements

### Separator Rules
- **Hyphen (`-`)**: Primary separator for internal name components
- **Underscore (`_`)**: Delimiter between VPC identifier and subnet designation
- **Avoid Colon (`:`)**: Ensures DevOps tool compatibility

## Component Definitions

### Prefix
Account-level functional identifiers:

| Prefix | Purpose |
|--------|---------|
| `network` | Core networking and connectivity services |
| `security` | Security tools and monitoring infrastructure |
| `devops` | CI/CD, development, and operations tooling |
| `log` | Logging and audit services |

### Zone
Functional areas within the Landing Zone:

| Zone | Purpose |
|------|---------|
| `dmz` | Demilitarized zone for public-facing services |
| `acc` | Access control and connectivity services |
| `sec` | Security operations and monitoring |
| `sha` | Security hub and analytics |
| `cbh` | Cloud bastion host services |
| `devop` | Development and operations services |

### Environment
Deployment stage identifiers:

| Environment | Purpose |
|-------------|---------|
| `dev` | Development environment |
| `nprd` | Non-production (staging/testing) |
| `prd` | Production environment |

### Service Abbreviations

| Service | Abbreviation | Full Name |
|---------|--------------|-----------|
| API Gateway | `apig` | API Gateway |
| Network Address Translation | `nat` | NAT Gateway |
| Elastic Load Balancer | `elb` | Elastic Load Balancer |
| Virtual Private Network | `vpn` | VPN Gateway |
| Direct Connect | `dc` | Direct Connect |
| Domain Name System | `dns` | DNS Services |
| Security Information Event Management | `siem` | SIEM Platform |
| Firewall | `fal` | Firewall Services |
| Security Hub | `sha` | Security Analytics Hub |
| Cloud Bastion Host | `cbh` | Cloud Bastion Host |
| Development Operations | `devop` | Development Operations |
| Enterprise Router | `er` | Enterprise Router |
| Cloud Firewall | `cfw` | Cloud Firewall |
| VPN Gateway | `vpngw` | VPN Gateway Service |
| Customer Gateway | `vpncgw` | VPN Customer Gateway |
| Resource Access Manager | `ram` | Resource Access Manager |
| Security Master | `secmaster` | Security Master Service |
| Object Storage Service | `obs` | Object Storage Service |

### Subnet Types

| Type | Purpose |
|------|---------|
| `public` | Internet-facing subnets |
| `private` | Internal-only subnets |

### Numbering Convention

- **1-99**: No padding required (`1`, `2`, `99`)
- **100-999**: Natural three digits (`100`, `101`, `999`)
- **1000+**: Four-digit extension (`1000`, `1001`)

## Extended Naming Formats

### Network Services

#### Enterprise Router (ER)
```
# ER Instance
{prefix}-{company}-{project}-{environment}-er{sequence}

# ER Attachment
{prefix}-er-attach-{resource-type}-{environment}-{sequence}

# ER Route Table
rtb-{prefix}-{direction}-{environment}-{sequence}
```

#### Cloud Firewall (CFW)
```
{prefix}-{company}-{project}-{environment}-cfw{sequence}
```

#### VPN Services
```
# VPN Gateway
{prefix}-{company}-{project}-{environment}-vpngw{sequence}

# VPN Customer Gateway
{prefix}-{company}-{project}-{environment}-vpncgw{sequence}

# VPN Connection
{prefix}-{company}-{project}-{environment}-vpn-connection{sequence}

# VPN Elastic IP
{prefix}-{company}-{project}-{environment}-vpngw-eip{sequence}
```

#### NAT Gateway
```
{prefix}-{company}-{project}-{environment}-nat{sequence}
```

### Security Services

#### Security Master
```
{prefix}-{company}-{project}-secmaster{sequence}
```

#### Cloud Bastion Host
```
{prefix}-{company}-{project}-cbh{sequence}
```

### Storage Services

#### Object Storage Service (OBS)
```
{prefix}-{company}-{project}-{purpose}-{environment}-{sequence}
```

### Shared Services

#### Resource Access Manager (RAM)
```
{prefix}-{company}-{project}-{environment}-er-instance-share{sequence}
```

## Examples

### VPC and Subnet Examples

#### Basic Naming (Single AZ Deployment)
```
# Network Account - DMZ Development Environment
VPC:    network-company-project-dmz-dev-vpc1
Subnet: company-project-dmz-dev-vpc1_apig-publicsubnet1
Subnet: company-project-dmz-dev-vpc1_nat-publicsubnet1
Subnet: company-project-dmz-dev-vpc1_elb-publicsubnet1
```

#### High Availability Naming (Multi-AZ Deployment)
```
# Network Account - DMZ Production Environment (Cross-AZ)
VPC:    network-company-project-dmz-prd-vpc1
Subnet: company-project-dmz-prd-vpc1_apig-public-3a-subnet1
Subnet: company-project-dmz-prd-vpc1_apig-public-3b-subnet1
Subnet: company-project-dmz-prd-vpc1_nat-public-3a-subnet1
Subnet: company-project-dmz-prd-vpc1_elb-public-3a-subnet1
Subnet: company-project-dmz-prd-vpc1_elb-public-3b-subnet1
```

#### Other Account Examples
```
# Security Account - Production Security Operations
VPC:    security-company-project-sec-prd-vpc1  
Subnet: company-project-sec-prd-vpc1_siem-privatesubnet1
Subnet: company-project-sec-prd-vpc1_fal-privatesubnet1

# DevOps Account - Non-Production Environment
VPC:    devops-company-project-devop-nprd-vpc1
Subnet: company-project-devop-nprd-vpc1_devop-privatesubnet1
```

### Network Services Examples

```
# Enterprise Router
Instance:    network-company-project-dev-er1
Attachment:  network-er-attach-dmz-dev-vpc-1
Route Table: rtb-network-forwarder-dev-1 / rtb-network-back-dev-1

# Cloud Firewall
network-company-project-dev-cfw1

# VPN Services
Gateway:      network-company-project-dev-vpngw1
Elastic IP:   network-company-project-dev-vpngw-eip1
Customer GW:  network-company-project-dev-vpncgw1
Connection:   network-company-project-dev-vpn-connection1

# NAT Gateway
network-company-project-dev-nat1
```

### Security Services Examples

```
# Security Master (Multi-Account)
network-company-project-secmaster1
security-company-project-secmaster1

# Cloud Bastion Host
security-company-project-cbh1
```

### Storage Services Examples

```
# OBS Buckets
security-company-project-log-archive-bucket-dev-1
```

### Shared Services Examples

```
# Resource Access Manager
network-company-project-dev-er-instance-share1
```

## Scaling Examples

### Multi-Environment Deployment
```
# Development Environment
network-company-project-dev-er1
network-company-project-dev-vpngw1
security-company-project-log-archive-bucket-dev-1

# Production Environment
network-company-project-prd-er1
network-company-project-prd-vpngw1
security-company-project-log-archive-bucket-prd-1
```

### Scaling Within Environment
```
# Multiple ER instances in production
network-company-project-prd-er1
network-company-project-prd-er2

# Multiple VPN connections
network-company-project-prd-vpn-connection1
network-company-project-prd-vpn-connection2
```

## Design Trade-offs

### Availability Zone Identifier Choice

Whether to include availability zone identifiers in subnet naming is an important design decision in enterprise deployments:

#### Advantages of Including AZ Identifiers
- **Clear High Availability Architecture**: Explicitly shows resource distribution across availability zones
- **Visible Fault Isolation**: Facilitates understanding and management of cross-AZ dependencies
- **Better Scalability**: Supports future multi-AZ expansion requirements
- **Operations Friendly**: Facilitates monitoring and troubleshooting

#### Considerations for Excluding AZ Identifiers
- **Simplified Initial Deployment**: Suitable for simple single-AZ scenarios
- **Reduced Learning Curve**: Lowers barrier to understanding and adoption
- **Avoid Over-Engineering**: Maintains simplicity in scenarios where high availability isn't required

#### Recommended Principles
- **Production Environments**: Strongly recommend using AZ identifiers
- **Development/Test Environments**: Choose based on actual requirements
- **Future Planning**: Consider business growth requirements for high availability

## Extension Guidelines

### Adding New Services
1. Create meaningful 3-5 character abbreviation
2. Add to service abbreviations table
3. Follow existing naming patterns

### Adding New Zones
1. Use descriptive 3-4 character identifier
2. Document purpose in zone definitions
3. Maintain consistency with existing patterns

### Adding New Environments
1. Use clear, abbreviated environment name
2. Update environment definitions table
3. Apply consistently across all resources

## Validation Rules

### Character Constraints
- **Allowed Characters**: `a-z`, `0-9`, `-`, `_`
- **Case**: Lowercase only
- **Length Limits**: VPC names ≤ 64 chars, Subnet names ≤ 64 chars

### Regular Expression Patterns
```regex
# VPC Pattern (supports 1-9999)
^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc([1-9][0-9]{0,3})$

# Subnet Pattern (supports 1-9999)
^[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc([1-9][0-9]{0,3})_[a-z]+-[a-z]+subnet([1-9][0-9]{0,3})$

# Service Resource Pattern (supports 1-9999)
^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]+-([1-9][0-9]{0,3})$
```

## Implementation Notes

### Tool Compatibility
- **Terraform**: Full compatibility with resource and variable naming
- **Ansible**: YAML-safe without escaping requirements
- **CLI Tools**: Direct usage without quotation marks
- **APIs**: URL-safe without encoding

### Migration Strategy
- **New Resources**: Apply convention immediately
- **Existing Resources**: Plan phased migration during maintenance windows
- **Documentation**: Update all references to use new naming

## Contributing

We welcome Issues and Pull Requests to improve this convention. Please ensure:

1. Changes have adequate justification and explanation
2. Maintain consistency with existing patterns
3. Update relevant examples and documentation
4. Consider backward compatibility implications

## License

MIT License

---

**Document Version**: 1.0  
**Last Updated**: 2025-05-26  
**Next Review**: 2025-11-26