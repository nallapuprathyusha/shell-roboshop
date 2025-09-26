#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-029dab38d39f77779" # replace with your SG ID

for instance in $@
do 
   INSTANCE_ID= $(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query 'Instances[0].InstanceId' --output text)

   


done