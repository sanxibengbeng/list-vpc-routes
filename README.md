# VPC Route Tables Exporter

A bash script that exports AWS VPC route table information to CSV format for easy analysis and documentation.

## Overview

This script retrieves all VPC route tables from your current AWS region and exports the information to a CSV file. It provides a comprehensive view of your VPC routing configuration including VPC details, route table information, and individual route entries.

## Features

- Exports VPC and route table data to CSV format
- Handles multiple VPCs and route tables in a single region
- Includes VPC names and route table names (from tags)
- Captures all route destinations, targets, and states
- Handles edge cases (no VPCs, no route tables, no routes)
- Clean CSV output with proper formatting

## Prerequisites

- AWS CLI installed and configured
- `jq` command-line JSON processor
- Appropriate AWS IAM permissions:
  - `ec2:DescribeVpcs`
  - `ec2:DescribeRouteTables`

## Installation

1. Clone this repository or download the script:
   ```bash
   git clone <repository-url>
   cd list-vpc-routes
   ```

2. Make the script executable:
   ```bash
   chmod +x list-vpc-routes.sh
   ```

3. Ensure dependencies are installed:
   ```bash
   # Install jq (macOS)
   brew install jq
   
   # Install jq (Ubuntu/Debian)
   sudo apt-get install jq
   
   # Install jq (CentOS/RHEL)
   sudo yum install jq
   ```

## Usage

Run the script from the command line:

```bash
./list-vpc-routes.sh
```

The script will:
1. Use your current AWS CLI region configuration
2. Query all VPCs in that region
3. For each VPC, retrieve all associated route tables
4. For each route table, extract all route entries
5. Export everything to `vpc_route_tables.csv`

## Output Format

The generated CSV file contains the following columns:

| Column | Description |
|--------|-------------|
| Region | AWS region where the VPC is located |
| VPC_ID | VPC identifier |
| VPC_Name | VPC name from the 'Name' tag |
| CIDR_Block | VPC CIDR block |
| Route_Table_ID | Route table identifier |
| Route_Table_Name | Route table name from the 'Name' tag |
| Destination_CIDR | Route destination CIDR block |
| Target | Route target (gateway, interface, etc.) |
| State | Route state (active, blackhole, etc.) |

## Example Output

```csv
Region,VPC_ID,VPC_Name,CIDR_Block,Route_Table_ID,Route_Table_Name,Destination_CIDR,Target,State
us-east-1,vpc-12345678,Production VPC,10.0.0.0/16,rtb-87654321,Main Route Table,10.0.0.0/16,local,active
us-east-1,vpc-12345678,Production VPC,10.0.0.0/16,rtb-87654321,Main Route Table,0.0.0.0/0,igw-abcdef12,active
```

## Configuration

The script uses your current AWS CLI configuration:

- **Region**: Uses `aws configure get region`
- **Credentials**: Uses your default AWS CLI profile

To use a different region or profile:

```bash
# Set different region
export AWS_DEFAULT_REGION=us-west-2

# Use different profile
export AWS_PROFILE=my-profile

# Then run the script
./list-vpc-routes.sh
```

## Error Handling

The script handles various scenarios:

- **No VPCs found**: Creates a CSV entry indicating no VPCs in the region
- **No route tables**: Indicates when a VPC has no route tables
- **No routes**: Shows when a route table has no route entries
- **Missing names**: Uses "No Name" for resources without Name tags

## Troubleshooting

### Common Issues

1. **Permission denied**:
   ```bash
   chmod +x list-vpc-routes.sh
   ```

2. **AWS CLI not configured**:
   ```bash
   aws configure
   ```

3. **jq not found**:
   ```bash
   # Install jq using your package manager
   brew install jq  # macOS
   ```

4. **No output or empty CSV**:
   - Check your AWS region configuration
   - Verify you have VPCs in the current region
   - Ensure proper IAM permissions

### Debug Mode

To see detailed AWS CLI output, remove the `AWS_PAGER=""` export or run with verbose output:

```bash
AWS_CLI_AUTO_PROMPT=on ./list-vpc-routes.sh
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review AWS CLI documentation
3. Open an issue in this repository
