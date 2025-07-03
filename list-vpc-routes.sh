#!/bin/bash

# 设置 AWS CLI 的输出格式
export AWS_PAGER=""

# 获取当前区域
REGION=$(aws configure get region)

# 输出 CSV 文件
OUTPUT_FILE="vpc_route_tables.csv"

# 写入 CSV 头部
echo "Region,VPC_ID,VPC_Name,CIDR_Block,Route_Table_ID,Route_Table_Name,Destination_CIDR,Target,State" > "$OUTPUT_FILE"

# 获取当前区域的所有 VPC
VPCS=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --query "Vpcs[].{VpcId:VpcId,CidrBlock:CidrBlock,Name:Tags[?Key=='Name'].Value|[0]}" \
  --output json)

# 检查是否为空
if [ -z "$VPCS" ] || [ "$VPCS" = "[]" ]; then
  echo "$REGION,,,,,,No VPCs Found,," >> "$OUTPUT_FILE"
  echo "No VPCs found in region $REGION. CSV output written to $OUTPUT_FILE."
  exit 0
fi

# 遍历每个 VPC
echo "$VPCS" | jq -c '.[]' | while read -r VPC; do
  VPC_ID=$(echo "$VPC" | jq -r '.VpcId')
  CIDR_BLOCK=$(echo "$VPC" | jq -r '.CidrBlock')
  VPC_NAME=$(echo "$VPC" | jq -r '.Name // "No Name"' | sed 's/,//g') # 移除名称中的逗号以避免 CSV 格式问题

  # 获取该 VPC 的路由表
  ROUTE_TABLES=$(aws ec2 describe-route-tables \
    --region "$REGION" \
    --filters Name=vpc-id,Values="$VPC_ID" \
    --query "RouteTables[].{RouteTableId:RouteTableId,Name:Tags[?Key=='Name'].Value|[0]}" \
    --output json)

  # 检查路由表是否为空
  if [ -z "$ROUTE_TABLES" ] || [ "$ROUTE_TABLES" = "[]" ]; then
    echo "$REGION,$VPC_ID,$VPC_NAME,$CIDR_BLOCK,,,No Route Tables,," >> "$OUTPUT_FILE"
    continue
  fi

  # 遍历每个路由表
  echo "$ROUTE_TABLES" | jq -c '.[]' | while read -r RT; do
    RT_ID=$(echo "$RT" | jq -r '.RouteTableId')
    RT_NAME=$(echo "$RT" | jq -r '.Name // "No Name"' | sed 's/,//g') # 移除名称中的逗号

    # 获取路由表中的路由规则
    ROUTES=$(aws ec2 describe-route-tables \
      --region "$REGION" \
      --route-table-ids "$RT_ID" \
      --query "RouteTables[0].Routes[].{Destination:DestinationCidrBlock,Target:GatewayId||NetworkInterfaceId||VpcPeeringConnectionId||NatGatewayId||TransitGatewayId||CarrierGatewayId||LocalGatewayId||EgressOnlyInternetGatewayId,State:State}" \
      --output json)

    # 检查路由规则是否为空
    if [ -z "$ROUTES" ] || [ "$ROUTES" = "[]" ]; then
      echo "$REGION,$VPC_ID,$VPC_NAME,$CIDR_BLOCK,$RT_ID,$RT_NAME,No Routes,," >> "$OUTPUT_FILE"
    else
      # 遍历路由规则并写入 CSV
      echo "$ROUTES" | jq -c '.[]' | while read -r ROUTE; do
        DEST=$(echo "$ROUTE" | jq -r '.Destination // "N/A"')
        TARGET=$(echo "$ROUTE" | jq -r '.Target // "N/A"')
        STATE=$(echo "$ROUTE" | jq -r '.State // "N/A"')
        echo "$REGION,$VPC_ID,$VPC_NAME,$CIDR_BLOCK,$RT_ID,$RT_NAME,$DEST,$TARGET,$STATE" >> "$OUTPUT_FILE"
      done
    fi
  done
done

echo "CSV output written to $OUTPUT_FILE"