#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-029dab38d39f77779"  # replace with your SG ID
DOMAIN="prathyusha.fun"  # replace with your domain name
HOSTZONE="Z0994508312PR2YKTSFA1" # replace with your hosted zone name

for instance in $@
do 

   INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
   
   if [ $instance != "frontend" ]; then

      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
      RECORDNAME=$instance.$DOMAIN
   else
      IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) 
      RECORDNAME=$DOMAIN


   fi
echo "$instance: $IP"

   aws route53 change-resource-record-sets --hosted-zone-id $HOSTZONE --change-batch '{
    "Comment": "Creating an A record for prathyusha.fun",
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORDNAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'$IP'"
            }
          ]
        }
      }
    ]
  }'
done