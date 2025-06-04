#!/bin/bash
# Batch validation script for Enterprise Landing Zone naming convention
# Usage: ./validate_all.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="${SCRIPT_DIR}/naming_validator.py"
VERBOSE=false
JSON_OUTPUT=false
EXIT_ON_ERROR=false

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [FILES...]

Validate Enterprise Landing Zone resource names against naming convention.

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -j, --json          Output results in JSON format
    -e, --exit-on-error Exit immediately if validation fails
    -t, --test-only     Only validate test_resources.txt
    
EXAMPLES:
    $0                          # Validate all found resource files
    $0 -v                       # Verbose validation
    $0 -j resource_names.txt    # JSON output for specific file
    $0 -e -t                    # Test mode with exit on error

EXIT CODES:
    0   All validations passed
    1   Some validations failed
    2   Script error (missing dependencies, files, etc.)
EOF
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is required but not installed."
        exit 2
    fi

    if [ ! -f "$VALIDATOR" ]; then
        log_error "naming_validator.py not found at $VALIDATOR"
        exit 2
    fi

    if [ ! -x "$VALIDATOR" ]; then
        chmod +x "$VALIDATOR"
    fi
}

# Extract resource names from Terraform files
extract_terraform_names() {
    local file="$1"
    log_info "Extracting names from Terraform file: $file"
    
    # Extract resource names from Terraform files
    grep -oP 'name\s*=\s*"\K[^"]+' "$file" 2>/dev/null | grep -E '^[a-z].*-.*[0-9]$' || true
}

# Extract resource names from Ansible files
extract_ansible_names() {
    local file="$1"
    log_info "Extracting names from Ansible file: $file"
    
    # Extract from YAML files
    grep -oP ':\s*"\K[^"]+' "$file" 2>/dev/null | grep -E '^[a-z].*-.*[0-9]$' || true
}

# Extract resource names from JSON files
extract_json_names() {
    local file="$1"
    log_info "Extracting names from JSON file: $file"
    
    # Extract from JSON files
    grep -oP '"\K[^"]+' "$file" 2>/dev/null | grep -E '^[a-z].*-.*[0-9]$' || true
}

# Validate a single file
validate_file() {
    local file="$1"
    local temp_file=""
    local validation_result=0
    
    if [ ! -f "$file" ]; then
        log_warning "File not found: $file"
        return 1
    fi
    
    log_info "Processing file: $file"
    
    case "$file" in
        *.tf)
            temp_file=$(mktemp)
            extract_terraform_names "$file" > "$temp_file"
            ;;
        *.yml|*.yaml)
            temp_file=$(mktemp)
            extract_ansible_names "$file" > "$temp_file"
            ;;
        *.json)
            temp_file=$(mktemp)
            extract_json_names "$file" > "$temp_file"
            ;;
        *.txt)
            temp_file="$file"
            ;;
        *)
            log_warning "Unknown file type: $file"
            return 1
            ;;
    esac
    
    if [ ! -s "$temp_file" ]; then
        log_warning "No resource names found in: $file"
        [ "$temp_file" != "$file" ] && rm -f "$temp_file"
        return 1
    fi
    
    # Run validation
    local validator_args="--file $temp_file"
    [ "$VERBOSE" = true ] && validator_args="$validator_args --verbose"
    [ "$JSON_OUTPUT" = true ] && validator_args="$validator_args --json"
    
    if python3 "$VALIDATOR" $validator_args; then
        log_success "Validation passed for: $file"
        validation_result=0
    else
        log_error "Validation failed for: $file"
        validation_result=1
    fi
    
    # Cleanup
    [ "$temp_file" != "$file" ] && rm -f "$temp_file"
    
    return $validation_result
}

# Main validation function
run_validation() {
    local files=("$@")
    local total_files=0
    local failed_files=0
    local exit_code=0
    
    if [ ${#files[@]} -eq 0 ]; then
        # Auto-discover files
        log_info "Auto-discovering resource files..."
        
        # Common locations to check
        local search_files=(
            "${SCRIPT_DIR}/test_resources.txt"
            "${SCRIPT_DIR}/../terraform/main.tf"
            "${SCRIPT_DIR}/../terraform/terraform.tfvars"
            "${SCRIPT_DIR}/../ansible/landing_zone_playbook.yml"
            "${SCRIPT_DIR}/../ansible/group_vars/all.yml"
            "terraform.tfvars"
            "main.tf"
            "resource_names.txt"
            "resources.txt"
        )
        
        for file in "${search_files[@]}"; do
            [ -f "$file" ] && files+=("$file")
        done
        
        if [ ${#files[@]} -eq 0 ]; then
            log_warning "No resource files found. Please specify files manually."
            return 1
        fi
    fi
    
    log_info "Starting validation of ${#files[@]} files..."
    echo
    
    for file in "${files[@]}"; do
        total_files=$((total_files + 1))
        
        if ! validate_file "$file"; then
            failed_files=$((failed_files + 1))
            
            if [ "$EXIT_ON_ERROR" = true ]; then
                log_error "Exiting on first error as requested"
                exit 1
            fi
        fi
        
        echo
    done
    
    # Summary
    echo "================================="
    echo "VALIDATION SUMMARY"
    echo "================================="
    echo "Total files processed: $total_files"
    echo "Failed validations: $failed_files"
    echo "Success rate: $(( (total_files - failed_files) * 100 / total_files ))%"
    
    if [ $failed_files -gt 0 ]; then
        log_error "$failed_files out of $total_files validations failed"
        exit_code=1
    else
        log_success "All validations passed!"
        exit_code=0
    fi
    
    return $exit_code
}

# Parse command line arguments
parse_args() {
    local files=()
    local test_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -j|--json)
                JSON_OUTPUT=true
                shift
                ;;
            -e|--exit-on-error)
                EXIT_ON_ERROR=true
                shift
                ;;
            -t|--test-only)
                test_only=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done
    
    if [ "$test_only" = true ]; then
        files=("${SCRIPT_DIR}/test_resources.txt")
    fi
    
    echo "${files[@]}"
}

# Main script execution
main() {
    echo "======================================================================="
    echo "Enterprise Landing Zone Naming Convention Validator"
    echo "======================================================================="
    echo
    
    # Check dependencies
    check_dependencies
    
    # Parse arguments
    local files
    mapfile -t files < <(parse_args "$@")
    
    # Run validation
    if run_validation "${files[@]}"; then
        log_success "All naming convention validations completed successfully!"
        exit 0
    else
        log_error "Some naming convention validations failed!"
        exit 1
    fi
}

# Handle script interruption
trap 'log_error "Script interrupted"; exit 130' INT TERM

# Run main function with all arguments
main "$@"