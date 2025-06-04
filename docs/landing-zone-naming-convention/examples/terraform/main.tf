# examples/terraform/main.tf
# Enterprise Landing Zone Naming Convention - Terraform Examples

# Local variables following the naming convention
locals {
  # Basic naming components
  company     = "acme"
  project     = "webapp"
  environment = "prd"
  
  # Network account prefix
  network_prefix = "network"
  security_prefix = "security"
  
  # Common tags
  common_tags = {
    Company     = local.company
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

# VPC following naming convention
resource "huaweicloud_vpc" "dmz_vpc" {
  name = "${local.network_prefix}-${local.company}-${local.project}-dmz-${local.environment}-vpc1"
  cidr = "10.0.0.0/16"
  
  tags = merge(local.common_tags, {
    Name = "${local.network_prefix}-${local.company}-${local.project}-dmz-${local.environment}-vpc1"
    Zone = "dmz"
    Type = "vpc"
  })
}

# Public subnets following naming convention
resource "huaweicloud_vpc_subnet" "apig_public_subnet" {
  name       = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_apig-publicsubnet1"
  cidr       = "10.0.1.0/24"
  gateway_ip = "10.0.1.1"
  vpc_id     = huaweicloud_vpc.dmz_vpc.id
  
  # Optional: For multi-AZ deployment, use this naming pattern instead:
  # name = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_apig-public-3a-subnet1"
  
  tags = merge(local.common_tags, {
    Name    = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_apig-publicsubnet1"
    Service = "apig"
    Type    = "public"
  })
}

resource "huaweicloud_vpc_subnet" "nat_public_subnet" {
  name       = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_nat-publicsubnet1"
  cidr       = "10.0.2.0/24"
  gateway_ip = "10.0.2.1"
  vpc_id     = huaweicloud_vpc.dmz_vpc.id
  
  tags = merge(local.common_tags, {
    Name    = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_nat-publicsubnet1"
    Service = "nat"
    Type    = "public"
  })
}

resource "huaweicloud_vpc_subnet" "elb_public_subnet" {
  name       = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_elb-publicsubnet1"
  cidr       = "10.0.3.0/24"
  gateway_ip = "10.0.3.1"
  vpc_id     = huaweicloud_vpc.dmz_vpc.id
  
  tags = merge(local.common_tags, {
    Name    = "${local.company}-${local.project}-dmz-${local.environment}-vpc1_elb-publicsubnet1"
    Service = "elb"
    Type    = "public"
  })
}

# Security VPC example
resource "huaweicloud_vpc" "security_vpc" {
  name = "${local.security_prefix}-${local.company}-${local.project}-sec-${local.environment}-vpc1"
  cidr = "10.1.0.0/16"
  
  tags = merge(local.common_tags, {
    Name = "${local.security_prefix}-${local.company}-${local.project}-sec-${local.environment}-vpc1"
    Zone = "sec"
    Type = "vpc"
  })
}

# Private subnets in security VPC
resource "huaweicloud_vpc_subnet" "siem_private_subnet" {
  name       = "${local.company}-${local.project}-sec-${local.environment}-vpc1_siem-privatesubnet1"
  cidr       = "10.1.1.0/24"
  gateway_ip = "10.1.1.1"
  vpc_id     = huaweicloud_vpc.security_vpc.id
  
  tags = merge(local.common_tags, {
    Name    = "${local.company}-${local.project}-sec-${local.environment}-vpc1_siem-privatesubnet1"
    Service = "siem"
    Type    = "private"
  })
}

# Enterprise Router following naming convention
resource "huaweicloud_er_instance" "main_er" {
  name                = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-er1"
  availability_zones  = ["ap-southeast-3a", "ap-southeast-3b"]
  
  tags = merge(local.common_tags, {
    Name    = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-er1"
    Service = "er"
  })
}

# ER attachment following naming convention
resource "huaweicloud_er_vpc_attachment" "dmz_attachment" {
  instance_id = huaweicloud_er_instance.main_er.id
  vpc_id      = huaweicloud_vpc.dmz_vpc.id
  subnet_id   = huaweicloud_vpc_subnet.apig_public_subnet.id
  name        = "${local.network_prefix}-er-attach-dmz-${local.environment}-vpc-1"
  
  tags = merge(local.common_tags, {
    Name        = "${local.network_prefix}-er-attach-dmz-${local.environment}-vpc-1"
    Service     = "er-attachment"
    Target      = "dmz-vpc"
  })
}

# NAT Gateway following naming convention
resource "huaweicloud_nat_gateway" "main_nat" {
  name        = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-nat1"
  spec        = "1"
  vpc_id      = huaweicloud_vpc.dmz_vpc.id
  subnet_id   = huaweicloud_vpc_subnet.nat_public_subnet.id
  
  tags = merge(local.common_tags, {
    Name    = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-nat1"
    Service = "nat"
  })
}

# VPN Gateway following naming convention
resource "huaweicloud_vpn_gateway" "main_vpn" {
  name               = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-vpngw1"
  vpc_id             = huaweicloud_vpc.dmz_vpc.id
  local_subnets      = [huaweicloud_vpc_subnet.apig_public_subnet.cidr]
  
  tags = merge(local.common_tags, {
    Name    = "${local.network_prefix}-${local.company}-${local.project}-${local.environment}-vpngw1"
    Service = "vpngw"
  })
}

# OBS Bucket following naming convention
resource "huaweicloud_obs_bucket" "log_archive" {
  bucket = "${local.security_prefix}-${local.company}-${local.project}-log-archive-bucket-${local.environment}-1"
  acl    = "private"
  
  tags = merge(local.common_tags, {
    Name    = "${local.security_prefix}-${local.company}-${local.project}-log-archive-bucket-${local.environment}-1"
    Service = "obs"
    Purpose = "log-archive"
  })
}

# Validation of naming convention
locals {
  # Validate VPC naming pattern
  vpc_name_valid = can(regex("^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc[1-9][0-9]*$", huaweicloud_vpc.dmz_vpc.name))
  
  # Validate subnet naming pattern  
  subnet_name_valid = can(regex("^[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc[1-9][0-9]*_[a-z]+-[a-z]+subnet[1-9][0-9]*$", huaweicloud_vpc_subnet.apig_public_subnet.name))
}

# Outputs
output "vpc_names" {
  description = "VPC names following naming convention"
  value = {
    dmz_vpc      = huaweicloud_vpc.dmz_vpc.name
    security_vpc = huaweicloud_vpc.security_vpc.name
  }
}

output "subnet_names" {
  description = "Subnet names following naming convention"
  value = {
    apig_public = huaweicloud_vpc_subnet.apig_public_subnet.name
    nat_public  = huaweicloud_vpc_subnet.nat_public_subnet.name
    elb_public  = huaweicloud_vpc_subnet.elb_public_subnet.name
    siem_private = huaweicloud_vpc_subnet.siem_private_subnet.name
  }
}

output "naming_validation" {
  description = "Naming convention validation results"
  value = {
    vpc_name_valid    = local.vpc_name_valid
    subnet_name_valid = local.subnet_name_valid
  }
}