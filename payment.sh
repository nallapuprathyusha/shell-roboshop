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

dnf install python3 gcc python3-devel -y
CHECK $? "installing python"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
CHECK $? "creating system user"

mkdir /app 
CHECK $? "creating app directory"

rm -rf app/*
CHECK $? "removing old files in directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
CHECK $? "downloading application files"

cd /app
CHECK $? "changing to app directory" 

unzip /tmp/payment.zip
CHECK $? "unziping the files"


pip3 install -r requirements.txt
CHECK $? "installing dependencies"

cp /root/shell-roboshop/payment.service /etc/systemd/system/payment.service
CHECK $? "creating payment services"


systemctl daemon-reload
CHECK $? "daemon reloading"

systemctl enable payment 
CHECK $? "enabling payment"

systemctl start payment
CHECK $? "starting payment"