# Naming Convention Validation Tools

This directory contains tools for validating Enterprise Landing Zone resource names against the established naming convention.

## Quick Start

```bash
# Make the validation script executable
chmod +x validate_all.sh

# Run validation on test resources
./validate_all.sh --test-only

# Validate all discovered files
./validate_all.sh

# Validate specific files with verbose output
./validate_all.sh -v main.tf resource_names.txt
```

## Files

| File | Description |
|------|-------------|
| `naming_validator.py` | Main Python validation script |
| `test_resources.txt` | Test resource names (valid and invalid examples) |
| `validate_all.sh` | Bash script for batch validation |
| `requirements.txt` | Python dependencies (optional) |
| `README.md` | This documentation |

## Usage

### Python Validator

The core validation tool supports multiple input methods:

#### Single Name Validation
```bash
python naming_validator.py --name "network-acme-webapp-dmz-prd-vpc1" --type vpc
```

#### File Validation
```bash
python naming_validator.py --file test_resources.txt
```

#### Interactive Mode
```bash
python naming_validator.py --interactive
```
Enter resource names one by one, press Enter on empty line to finish.

#### Stdin Input
```bash
echo "network-acme-webapp-dmz-prd-vpc1" | python naming_validator.py --stdin

# Or from a pipeline
grep "resource_name" config.tf | cut -d'"' -f2 | python naming_validator.py --stdin
```

#### JSON Output
```bash
python naming_validator.py --file test_resources.txt --json
```

### Batch Validation Script

The bash script provides additional features for batch processing:

#### Basic Usage
```bash
# Auto-discover and validate all resource files
./validate_all.sh

# Validate only test resources
./validate_all.sh --test-only

# Verbose output
./validate_all.sh --verbose

# JSON output
./validate_all.sh --json

# Exit on first error
./validate_all.sh --exit-on-error
```

#### Advanced Usage
```bash
# Validate specific files
./validate_all.sh terraform/main.tf ansible/playbook.yml

# Combine options
./validate_all.sh -v -e terraform/*.tf
```

## Supported File Types

The validation tools can extract resource names from:

- **Terraform files** (`.tf`): Extracts from `name = "..."` declarations
- **Ansible files** (`.yml`, `.yaml`): Extracts from YAML string values
- **JSON files** (`.json`): Extracts from JSON string values
- **Text files** (`.txt`): Treats each line as a resource name

## Validation Rules

The validator checks for:

### 1. Character Constraints
- Only lowercase letters (`a-z`)
- Numbers (`0-9`) 
- Hyphens (`-`)
- Underscores (`_`)
- Maximum length: 64 characters

### 2. Pattern Compliance
Each resource type has a specific pattern:

#### VPC Pattern
```
{prefix}-{company}-{project}-{zone}-{environment}-vpc{sequence}
```
Example: `network-acme-webapp-dmz-prd-vpc1`

#### Subnet Pattern (Single AZ)
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}subnet{sequence}
```
Example: `acme-webapp-dmz-prd-vpc1_apig-publicsubnet1`

#### Subnet Pattern (Multi-AZ)
```
{company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}-{az}-subnet{sequence}
```
Example: `acme-webapp-dmz-prd-vpc1_apig-public-3a-subnet1`

#### Service Pattern
```
{prefix}-{company}-{project}-{zone}-{service}-{sequence}
```
Example: `network-acme-webapp-prd-er1`

### 3. Component Validation
- **Prefixes**: `network`, `security`, `devops`, `log`
- **Environments**: `dev`, `nprd`, `prd`
- **Zones**: `dmz`, `acc`, `sec`, `sha`, `cbh`, `devop`
- **Subnet Types**: `public`, `private`
- **Sequence Numbers**: Start from 1, not 0

### 4. Service Abbreviations
The validator recognizes these service abbreviations:
- `apig` - API Gateway
- `nat` - NAT Gateway
- `elb` - Elastic Load Balancer
- `vpngw` - VPN Gateway
- `er` - Enterprise Router
- `siem` - SIEM Platform
- `fal` - Firewall Services
- `cbh` - Cloud Bastion Host
- And [many more](../README.md#service-abbreviations)

## Output Examples

### Valid Name
```
✓ network-acme-webapp-dmz-prd-vpc1 (vpc)
```

### Invalid Name with Suggestions
```
✗ Network-Acme-WebApp-DMZ-PRD-VPC1 (vpc)
    ERROR: Name contains invalid characters. Only lowercase letters, numbers, hyphens, and underscores are allowed.
    SUGGESTION: Convert all letters to lowercase
    SUGGESTION: VPC format: {prefix}-{company}-{project}-{zone}-{environment}-vpc{sequence}
```

### Detailed Report
```
================================================================================
ENTERPRISE LANDING ZONE NAMING CONVENTION VALIDATION REPORT
================================================================================
Total Resources: 25
Valid Names: 18
Invalid Names: 7
Success Rate: 72.0%

## VPC Resources (4/5 valid)
✓ network-acme-webapp-dmz-prd-vpc1
✗ Network-Acme-WebApp-DMZ-PRD-VPC1
    ERROR: Name contains invalid characters...
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Validate Naming Convention
on: [push, pull_request]

jobs:
  validate-names:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Validate resource names
        run: |
          chmod +x validation/validate_all.sh
          validation/validate_all.sh --exit-on-error
```

### GitLab CI
```yaml
validate-naming:
  stage: validate
  image: python:3.9-slim
  script:
    - chmod +x validation/validate_all.sh
    - validation/validate_all.sh --exit-on-error
  rules:
    - changes:
        - "**/*.tf"
        - "**/*.yml"
        - "**/resource_names.txt"
```

### Pre-commit Hook
Create `.git/hooks/pre-commit`:
```bash
#!/bin/sh
validation/validate_all.sh --exit-on-error --test-only
if [ $? -ne 0 ]; then
    echo "❌ Naming convention validation failed!"
    echo "Please fix naming issues before committing."
    exit 1
fi
echo "✅ Naming convention validation passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Terraform Plan Integration
```bash
# Extract resource names from Terraform plan
terraform plan -out=plan.out
terraform show -json plan.out | jq -r '.planned_values.root_module.resources[].values.name' | validation/naming_validator.py --stdin
```

## Customization

### Adding New Service Abbreviations
Edit `naming_validator.py` and add to the `service_abbreviations` dictionary:
```python
self.service_abbreviations = {
    # ... existing abbreviations ...
    "newservice": "New Service Description",
}
```

### Adding New Zones
Add to the `valid_zones` list:
```python
self.valid_zones = ["dmz", "acc", "sec", "sha", "cbh", "devop", "newzone"]
```

### Custom Validation Patterns
Override patterns in the `patterns` dictionary:
```python
self.patterns = {
    ResourceType.CUSTOM: r"^custom-pattern-regex$",
    # ... existing patterns ...
}
```

## Troubleshooting

### Common Issues

#### Permission Denied
```bash
chmod +x validate_all.sh
chmod +x naming_validator.py
```

#### Python Not Found
```bash
# Install Python 3
sudo apt-get install python3  # Ubuntu/Debian
brew install python3          # macOS
```

#### No Resource Names Found
- Check file format and content
- Verify the extraction patterns match your file structure
- Use `--verbose` flag for debugging

#### Large Numbers Warning
Sequence numbers > 99 generate warnings. This is normal for large deployments.

### Debug Mode
Run with verbose output to see detailed processing:
```bash
python naming_validator.py --file test_resources.txt --verbose
./validate_all.sh --verbose
```

## Contributing

To improve the validation tools:

1. Add test cases to `test_resources.txt`
2. Update patterns in `naming_validator.py`
3. Enhance file extraction logic in `validate_all.sh`
4. Update documentation

## Support

For issues or questions:
1. Check this README
2. Review test examples in `test_resources.txt`
3. Run in verbose mode for debugging
4. Open an issue with example names and error messages