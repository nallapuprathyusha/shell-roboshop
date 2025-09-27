#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/shell-scripting"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )

LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log

mkdir -p  $LOG_FOLDER

echo  $LOG_FILE
#tee -a <File_name> -  display output and stores in file
#&>> -<file_name> dont display the output ,just stores the output


if [ $USERID -ne 0 ]; then
    echo "your not root user please switch to root user" | tee -a $LOG_FILE
fi

CHECK()
{
    if [ $? -ne 0 ]; then
       echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE 
       
        
   else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
    
}

dnf list installed nodejs &>> $LOG_FILE
CHECK $? "nodejs installation status::"

dnf module disable nodejs -y &>> $LOG_FILE
CHECK $? "nodejs disabl status::"

dnf module enable nodejs:20 -y &>> $LOG_FILE
CHECK $? "nodejs enable status::"

dnf install nodejs -y  &>> $LOG_FILE
CHECK $? "nodejs installed status::"

#checking user already available or not if not available it will create if available it will skip
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    CHECK $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
CHECK $? "app directory status::"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
CHECK $? "Downloading files"

cd /app &>> $LOG_FILE
CHECK $? "Going into directory"

rm -rf /app/*
CHECK $? "Removing existing code"


unzip /tmp/catalogue.zip &>> $LOG_FILE
CHECK $? "Unzip the files in app directory"


npm install &>> $LOG_FILE
CHECK $? "Installing denpendencies"

cp /root/shell-roboshop/catalogue.service /etc/systemd/system/catalogue.service
CHECK $? "copying catalogue serice file to systemd"

systemctl daemon-reload &>> $LOG_FILE
CHECK $? "daemon-reload"

systemctl enable catalogue &>> $LOG_FILE
CHECK $? "enabling catalogue" 

systemctl start catalogue &>> $LOG_FILE
CHECK $? "starting catalogue"


cp /root/shell-roboshop/mongo.repo /etc/yum.repos.d
CHECK $? "copying mongo repo file to repository"

dnf install mongodb-mongosh -y &>> $LOG_FILE
CHECK $? "Installing mongo client"

mongosh --host mongo.prathyusha.fun </app/db/master-data.js &>> $LOG_FILE
CHECK $? "loading schema" #adding products details in mongodb database server



