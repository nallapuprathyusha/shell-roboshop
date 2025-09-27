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

dnf list installed nodejs  &>> $LOG_FILE
CHECK $? "checking availability of nodejs"

dnf module disable nodejs -y &>> $LOG_FILE
CHECK $? "diable nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
CHECK $? "enable nodejs"

dnf install nodejs -y &>> $LOG_FILE
CHECK $? "intall nodejs"


#checking user already available or not if not available it will create if available it will skip
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    CHECK $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOG_FILE
CHECK $? "creating app director"


curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>> $LOG_FILE
CHECK $? "Downloading user application"

cd /app &>> $LOG_FILE
CHECK $? "Changing directory"

rm -rf /app/* &>> $LOG_FILE
CHECK $? "Removing existing code"

unzip /tmp/user.zip &>> $LOG_FILE
CHECK $? "unziping files"

npm install  &>> $LOG_FILE
CHECK $? "installing denpencies"

cp /root/shell-roboshop/user.service /etc/systemd/system/user.service &>> $LOG_FILE
CHECK $? "Copy systemctl service"

systemctl daemon-reload
CHECK $? "daemon reload"

systemctl enable user &>> $LOG_FILE
CHECK $? "Enabling user"

systemctl start user &>> $LOG_FILE
CHECK $? "Starting user"


