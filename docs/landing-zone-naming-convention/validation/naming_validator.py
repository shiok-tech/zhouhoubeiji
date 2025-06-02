#!/usr/bin/env python3
"""
Enterprise Landing Zone Naming Convention Validator

This script validates cloud resource names against the enterprise naming convention
and provides detailed feedback on compliance and suggestions for improvement.

Usage:
    python naming_validator.py --name "network-acme-webapp-dmz-prd-vpc1" --type vpc
    python naming_validator.py --file resources.txt
    python naming_validator.py --interactive
"""

import re
import argparse
import sys
import json
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


class ResourceType(Enum):
    VPC = "vpc"
    SUBNET = "subnet"
    SUBNET_WITH_AZ = "subnet_with_az"
    SERVICE = "service"
    OBS_BUCKET = "obs_bucket"


@dataclass
class ValidationResult:
    """Represents the result of a name validation"""
    is_valid: bool
    resource_type: ResourceType
    name: str
    errors: List[str]
    warnings: List[str]
    suggestions: List[str]
    parsed_components: Optional[Dict[str, str]] = None


class NamingValidator:
    """Enterprise Landing Zone Naming Convention Validator"""
    
    def __init__(self):
        self.patterns = {
            ResourceType.VPC: r"^(network|security|devops|log)-([a-z]+)-([a-z]+)-([a-z]{3,4})-([a-z]{3,4})-vpc([1-9][0-9]*)$",
            ResourceType.SUBNET: r"^([a-z]+)-([a-z]+)-([a-z]{3,4})-([a-z]{3,4})-vpc([1-9][0-9]*)_([a-z]+)-([a-z]+)subnet([1-9][0-9]*)$",
            ResourceType.SUBNET_WITH_AZ: r"^([a-z]+)-([a-z]+)-([a-z]{3,4})-([a-z]{3,4})-vpc([1-9][0-9]*)_([a-z]+)-([a-z]+)-([0-9][a-z])-subnet([1-9][0-9]*)$",
            ResourceType.SERVICE: r"^(network|security|devops|log)-([a-z]+)-([a-z]+)-([a-z]{3,4})-([a-z]+)-([1-9][0-9]*)$",
            ResourceType.OBS_BUCKET: r"^(network|security|devops|log)-([a-z]+)-([a-z]+)-([a-z]+)-([a-z]+)-bucket-([a-z]{3,4})-([1-9][0-9]*)$"
        }
        
        self.valid_prefixes = ["network", "security", "devops", "log"]
        self.valid_zones = ["dmz", "acc", "sec", "sha", "cbh", "devop"]
        self.valid_environments = ["dev", "nprd", "prd"]
        self.valid_subnet_types = ["public", "private"]
        
        self.service_abbreviations = {
            "apig": "API Gateway",
            "nat": "NAT Gateway", 
            "elb": "Elastic Load Balancer",
            "vpn": "VPN Gateway",
            "dc": "Direct Connect",
            "dns": "DNS Services",
            "siem": "SIEM Platform",
            "fal": "Firewall Services",
            "sha": "Security Analytics Hub",
            "cbh": "Cloud Bastion Host",
            "devop": "Development Operations",
            "er": "Enterprise Router",
            "cfw": "Cloud Firewall",
            "vpngw": "VPN Gateway Service",
            "vpncgw": "VPN Customer Gateway",
            "ram": "Resource Access Manager",
            "secmaster": "Security Master Service",
            "obs": "Object Storage Service"
        }
    
    def detect_resource_type(self, name: str) -> ResourceType:
        """Detect the resource type based on the name pattern"""
        # Check for VPC pattern
        if re.search(r"-vpc\d+$", name):
            return ResourceType.VPC
        
        # Check for subnet patterns
        if "_" in name and "subnet" in name:
            if re.search(r"-\d[a-z]-subnet\d+$", name):
                return ResourceType.SUBNET_WITH_AZ
            else:
                return ResourceType.SUBNET
        
        # Check for OBS bucket
        if "bucket" in name:
            return ResourceType.OBS_BUCKET
        
        # Default to service
        return ResourceType.SERVICE
    
    def validate_name(self, name: str, resource_type: Optional[ResourceType] = None) -> ValidationResult:
        """Validate a resource name against the naming convention"""
        if resource_type is None:
            resource_type = self.detect_resource_type(name)
        
        result = ValidationResult(
            is_valid=False,
            resource_type=resource_type,
            name=name,
            errors=[],
            warnings=[],
            suggestions=[]
        )
        
        # Basic character validation
        if not re.match(r"^[a-z0-9_-]+$", name):
            result.errors.append("Name contains invalid characters. Only lowercase letters, numbers, hyphens, and underscores are allowed.")
            return result
        
        # Length validation
        if len(name) > 64:
            result.errors.append(f"Name is too long ({len(name)} characters). Maximum length is 64 characters.")
        
        # Pattern validation
        pattern = self.patterns[resource_type]
        match = re.match(pattern, name)
        
        if not match:
            result.errors.append(f"Name does not match the {resource_type.value} naming pattern.")
            self._suggest_corrections(name, resource_type, result)
            return result
        
        # Parse components and validate
        result.parsed_components = self._parse_components(match, resource_type)
        self._validate_components(result)
        
        if not result.errors:
            result.is_valid = True
        
        return result
    
    def _parse_components(self, match, resource_type: ResourceType) -> Dict[str, str]:
        """Parse name components from regex match"""
        groups = match.groups()
        
        if resource_type == ResourceType.VPC:
            return {
                "prefix": groups[0],
                "company": groups[1],
                "project": groups[2],
                "zone": groups[3],
                "environment": groups[4],
                "sequence": groups[5]
            }
        elif resource_type == ResourceType.SUBNET:
            return {
                "company": groups[0],
                "project": groups[1],
                "zone": groups[2],
                "environment": groups[3],
                "vpc_sequence": groups[4],
                "service": groups[5],
                "subnet_type": groups[6],
                "subnet_sequence": groups[7]
            }
        elif resource_type == ResourceType.SUBNET_WITH_AZ:
            return {
                "company": groups[0],
                "project": groups[1],
                "zone": groups[2],
                "environment": groups[3],
                "vpc_sequence": groups[4],
                "service": groups[5],
                "subnet_type": groups[6],
                "availability_zone": groups[7],
                "subnet_sequence": groups[8]
            }
        elif resource_type == ResourceType.SERVICE:
            return {
                "prefix": groups[0],
                "company": groups[1],
                "project": groups[2],
                "zone": groups[3],
                "service": groups[4],
                "sequence": groups[5]
            }
        elif resource_type == ResourceType.OBS_BUCKET:
            return {
                "prefix": groups[0],
                "company": groups[1],
                "project": groups[2],
                "purpose": groups[3],
                "type": groups[4],
                "environment": groups[5],
                "sequence": groups[6]
            }
        
        return {}
    
    def _validate_components(self, result: ValidationResult):
        """Validate individual components of the parsed name"""
        components = result.parsed_components
        
        # Validate prefix
        if "prefix" in components and components["prefix"] not in self.valid_prefixes:
            result.errors.append(f"Invalid prefix '{components['prefix']}'. Valid prefixes: {', '.join(self.valid_prefixes)}")
        
        # Validate zone
        if "zone" in components and components["zone"] not in self.valid_zones:
            result.warnings.append(f"Uncommon zone '{components['zone']}'. Common zones: {', '.join(self.valid_zones)}")
        
        # Validate environment
        if "environment" in components and components["environment"] not in self.valid_environments:
            result.errors.append(f"Invalid environment '{components['environment']}'. Valid environments: {', '.join(self.valid_environments)}")
        
        # Validate subnet type
        if "subnet_type" in components and components["subnet_type"] not in self.valid_subnet_types:
            result.warnings.append(f"Uncommon subnet type '{components['subnet_type']}'. Common types: {', '.join(self.valid_subnet_types)}")
        
        # Validate service abbreviation
        if "service" in components and components["service"] not in self.service_abbreviations:
            result.warnings.append(f"Unknown service abbreviation '{components['service']}'. Consider adding to the service dictionary.")
        
        # Validate availability zone format
        if "availability_zone" in components:
            az = components["availability_zone"]
            if not re.match(r"^\d[a-z]$", az):
                result.errors.append(f"Invalid availability zone format '{az}'. Expected format: '3a', '3b', etc.")
        
        # Validate sequence numbers
        for key in ["sequence", "vpc_sequence", "subnet_sequence"]:
            if key in components:
                seq = int(components[key])
                if seq == 0:
                    result.errors.append(f"Sequence numbers must start from 1, not 0.")
                elif seq > 9999:
                    result.warnings.append(f"Large sequence number ({seq}). Consider if this is intended.")
    
    def _suggest_corrections(self, name: str, resource_type: ResourceType, result: ValidationResult):
        """Provide suggestions for correcting invalid names"""
        suggestions = []
        
        # Common fixes
        if any(c.isupper() for c in name):
            suggestions.append("Convert all letters to lowercase")
        
        if ":" in name:
            suggestions.append("Replace colons (:) with hyphens (-)")
        
        if resource_type == ResourceType.VPC and not name.endswith("-vpc1"):
            suggestions.append("VPC names should end with '-vpc1' (or higher sequence number)")
        
        if resource_type in [ResourceType.SUBNET, ResourceType.SUBNET_WITH_AZ] and "_" not in name:
            suggestions.append("Subnet names should use underscore (_) to separate VPC identifier from subnet designation")
        
        # Pattern-specific suggestions
        if resource_type == ResourceType.VPC:
            suggestions.append("VPC format: {prefix}-{company}-{project}-{zone}-{environment}-vpc{sequence}")
        elif resource_type == ResourceType.SUBNET:
            suggestions.append("Subnet format: {company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}subnet{sequence}")
        elif resource_type == ResourceType.SUBNET_WITH_AZ:
            suggestions.append("Multi-AZ subnet format: {company}-{project}-{zone}-{environment}-vpc{sequence}_{service}-{type}-{az}-subnet{sequence}")
        
        result.suggestions.extend(suggestions)
    
    def validate_batch(self, names: List[str]) -> List[ValidationResult]:
        """Validate a batch of resource names"""
        return [self.validate_name(name) for name in names]
    
    def generate_report(self, results: List[ValidationResult]) -> str:
        """Generate a comprehensive validation report"""
        total = len(results)
        valid = sum(1 for r in results if r.is_valid)
        invalid = total - valid
        
        report = [
            "=" * 80,
            "ENTERPRISE LANDING ZONE NAMING CONVENTION VALIDATION REPORT",
            "=" * 80,
            f"Total Resources: {total}",
            f"Valid Names: {valid}",
            f"Invalid Names: {invalid}",
            f"Success Rate: {(valid/total*100):.1f}%",
            "",
        ]
        
        # Group by resource type
        by_type = {}
        for result in results:
            if result.resource_type not in by_type:
                by_type[result.resource_type] = []
            by_type[result.resource_type].append(result)
        
        for resource_type, type_results in by_type.items():
            type_valid = sum(1 for r in type_results if r.is_valid)
            type_total = len(type_results)
            
            report.extend([
                f"## {resource_type.value.upper()} Resources ({type_valid}/{type_total} valid)",
                ""
            ])
            
            for result in type_results:
                status = "✓" if result.is_valid else "✗"
                report.append(f"{status} {result.name}")
                
                if result.errors:
                    for error in result.errors:
                        report.append(f"    ERROR: {error}")
                
                if result.warnings:
                    for warning in result.warnings:
                        report.append(f"    WARNING: {warning}")
                
                if result.suggestions:
                    for suggestion in result.suggestions:
                        report.append(f"    SUGGESTION: {suggestion}")
                
                if result.parsed_components:
                    report.append(f"    COMPONENTS: {result.parsed_components}")
                
                report.append("")
        
        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(
        description="Validate Enterprise Landing Zone resource names",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python naming_validator.py --name "network-acme-webapp-dmz-prd-vpc1" --type vpc
  python naming_validator.py --file resources.txt
  python naming_validator.py --interactive
  echo "network-acme-webapp-dmz-prd-vpc1" | python naming_validator.py --stdin
        """
    )
    
    parser.add_argument("--name", help="Single resource name to validate")
    parser.add_argument("--type", choices=[t.value for t in ResourceType], help="Resource type (auto-detected if not specified)")
    parser.add_argument("--file", help="File containing resource names (one per line)")
    parser.add_argument("--stdin", action="store_true", help="Read names from stdin")
    parser.add_argument("--interactive", action="store_true", help="Interactive mode")
    parser.add_argument("--json", action="store_true", help="Output results in JSON format")
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    validator = NamingValidator()
    results = []
    
    try:
        if args.interactive:
            print("Enterprise Landing Zone Naming Convention Validator")
            print("Enter resource names (empty line to finish):")
            while True:
                name = input("> ").strip()
                if not name:
                    break
                result = validator.validate_name(name)
                print_result(result, args.verbose)
        
        elif args.name:
            resource_type = ResourceType(args.type) if args.type else None
            result = validator.validate_name(args.name, resource_type)
            results = [result]
        
        elif args.file:
            with open(args.file, 'r') as f:
                names = [line.strip() for line in f if line.strip()]
            results = validator.validate_batch(names)
        
        elif args.stdin:
            names = [line.strip() for line in sys.stdin if line.strip()]
            results = validator.validate_batch(names)
        
        else:
            parser.print_help()
            return
        
        if results:
            if args.json:
                output = []
                for result in results:
                    output.append({
                        "name": result.name,
                        "valid": result.is_valid,
                        "type": result.resource_type.value,
                        "errors": result.errors,
                        "warnings": result.warnings,
                        "suggestions": result.suggestions,
                        "components": result.parsed_components
                    })
                print(json.dumps(output, indent=2))
            else:
                if len(results) == 1:
                    print_result(results[0], args.verbose)
                else:
                    print(validator.generate_report(results))
    
    except KeyboardInterrupt:
        print("\nValidation interrupted.")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def print_result(result: ValidationResult, verbose: bool = False):
    """Print a single validation result"""
    status = "VALID" if result.is_valid else "INVALID"
    print(f"{status}: {result.name} ({result.resource_type.value})")
    
    if result.errors:
        print("Errors:")
        for error in result.errors:
            print(f"  - {error}")
    
    if result.warnings:
        print("Warnings:")
        for warning in result.warnings:
            print(f"  - {warning}")
    
    if result.suggestions:
        print("Suggestions:")
        for suggestion in result.suggestions:
            print(f"  - {suggestion}")
    
    if verbose and result.parsed_components:
        print("Components:")
        for key, value in result.parsed_components.items():
            print(f"  {key}: {value}")
    
    print()


if __name__ == "__main__":
    main()