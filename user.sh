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

dnf list installed nodejs
CHECK $? "checking availability of nodejs"

dnf module disable nodejs -y
CHECK $? "diable nodejs"

dnf module enable nodejs:20 -y
CHECK $? "enable nodejs"

dnf install nodejs
CHECK $? "intall nodejs"


useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
CHECK $? "adding system user"

mkdir /app 
CHECK $? "creating app director"


curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
CHECK $? "Downloading user application"

cd /app 
CHECK $? "Changing directory"

rm -rf /app/*
CHECK $? "Removing existing code"

unzip /tmp/user.zip
CHECK $? "unziping files"

npm install 
CHECK $? "installing denpencies"

cp /root/shell-roboshop/user.service /etc/systemd/system/user.service
CHECK $? "Copy systemctl service"

systemctl enable user 
CHECK $? "Enabling user"

systemctl start user
CHECK $? "Starting user"


