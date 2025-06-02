# examples/terraform/variables.tf
# Variables for Enterprise Landing Zone Naming Convention

variable "company" {
  description = "Company identifier for naming convention"
  type        = string
  default     = "acme"
  
  validation {
    condition     = can(regex("^[a-z]+$", var.company))
    error_message = "Company must contain only lowercase letters."
  }
}

variable "project" {
  description = "Project identifier for naming convention"
  type        = string
  default     = "webapp"
  
  validation {
    condition     = can(regex("^[a-z]+$", var.project))
    error_message = "Project must contain only lowercase letters."
  }
}

variable "environment" {
  description = "Environment identifier (dev, nprd, prd)"
  type        = string
  default     = "prd"
  
  validation {
    condition     = contains(["dev", "nprd", "prd"], var.environment)
    error_message = "Environment must be one of: dev, nprd, prd."
  }
}

variable "network_prefix" {
  description = "Network account prefix"
  type        = string
  default     = "network"
  
  validation {
    condition     = contains(["network", "security", "devops", "log"], var.network_prefix)
    error_message = "Prefix must be one of: network, security, devops, log."
  }
}

variable "use_availability_zones" {
  description = "Whether to include availability zone identifiers in subnet names"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["3a", "3b", "3c"]
  
  validation {
    condition = alltrue([
      for az in var.availability_zones : can(regex("^[0-9][a-z]$", az))
    ])
    error_message = "Availability zones must follow pattern like '3a', '3b', '3c'."
  }
}

variable "vpc_cidrs" {
  description = "CIDR blocks for VPCs"
  type = map(string)
  default = {
    dmz      = "10.0.0.0/16"
    security = "10.1.0.0/16"
    devops   = "10.2.0.0/16"
  }
}

variable "enable_multi_az" {
  description = "Enable multi-availability zone deployment"
  type        = bool
  default     = false
}

# Computed locals for naming
locals {
  # Generate subnet names based on AZ usage
  subnet_name_format = var.use_availability_zones ? "%s-%s-%s-%s-vpc%d_%s-%s-%s-subnet%d" : "%s-%s-%s-%s-vpc%d_%s-%s-subnet%d"
  
  # AZ suffix for subnet names
  az_suffix = var.use_availability_zones ? var.availability_zones[0] : ""
  
  # Common naming components
  naming_components = {
    company     = var.company
    project     = var.project
    environment = var.environment
    prefix      = var.network_prefix
  }
  
  # Validation patterns
  validation_patterns = {
    vpc_pattern    = "^(network|security|devops|log)-[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc[1-9][0-9]*$"
    subnet_pattern = var.use_availability_zones ? 
      "^[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc[1-9][0-9]*_[a-z]+-[a-z]+-[0-9][a-z]-subnet[1-9][0-9]*$" :
      "^[a-z]+-[a-z]+-[a-z]{3,4}-[a-z]{3,4}-vpc[1-9][0-9]*_[a-z]+-[a-z]+subnet[1-9][0-9]*$"
  }
}