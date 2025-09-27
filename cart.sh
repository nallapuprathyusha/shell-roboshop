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

dnf module disable nodejs -y &>>$LOG_FILE
CHECK $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
CHECK $? "Enabling nodejs 20 version"

dnf install nodejs -y &>>$LOG_FILE
CHECK $? "Installing nodejs"

id roboshop &>>$$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
    CHECK $? "Adding Application user"
else
    echo "User already exist"

fi


mkdir -p /app &>>$LOG_FILE
CHECK $? "Creating App directory"

rm -rf /app/*
CHECK $? "Creating App directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
CHECK $? "Dowloading backend files"

cd /app &>>$LOG_FILE
CHECK $? "Switching to app directory"

unzip /tmp/cart.zip &>>$LOG_FILE
CHECK $? "Unzipping the app files"


npm install &>>$LOG_FILE
CHECK $? "installing dependency packages"

cp /root/Roboshop/cart.service /etc/systemd/system/cart.service
CHECK $? "Copying the user service file to systemd"

systemctl daemon-reload 
CHECK $? "Reloading cart service"

systemctl enable cart &>>$LOG_FILE
CHECK $? "Enabling cart service"


systemctl start cart &>>$LOG_FILE
CHECK $? "Starting cart service"
