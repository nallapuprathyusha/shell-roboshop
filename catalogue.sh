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
       exit 1
        
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

#checking user already available or not if not avaible it will create if available it will skip
id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
CHECK $? "app directory status::"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
CHECK $? "Downloading files"

cd /app
CHECK $? "Going into directory"

unzip /tmp/catalogue.zip
CHECK $? "Unzip the files in app directory"


npm install 
CHECK $? "Installing denpendencies"

cp /root/shell-roboshop/catalogue.service /etc/systemd/system/
CHECK $? "copying catalogue serice file to systemd"

systemctl daemon-reload
CHECK $? "daemon-reload"

systemctl enable catalogue
CHECK $? "enabling catalogue" 

systemctl start catalogue
CHECK $? "starting catalogue"


dnf install mongodb-mongosh -y
CHECK $? "Installing mongo client"

