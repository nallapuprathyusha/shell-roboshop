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

dnf install python3 gcc python3-devel -y   &>> $LOG_FILE
CHECK $? "installing python"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop   &>> $LOG_FILE
CHECK $? "creating system user"

mkdir /app   &>> $LOG_FILE
CHECK $? "creating app directory"

rm -rf app/*   &>> $LOG_FILE
CHECK $? "removing old files in directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip    &>> $LOG_FILE
CHECK $? "downloading application files"

cd /app   &>> $LOG_FILE
CHECK $? "changing to app directory" 

unzip /tmp/payment.zip   &>> $LOG_FILE
CHECK $? "unziping the files"


pip3 install -r requirements.txt   &>> $LOG_FILE
CHECK $? "installing dependencies"

cp /root/shell-roboshop/payment.service /etc/systemd/system/payment.service   &>> $LOG_FILE
CHECK $? "creating payment services"


systemctl daemon-reload   &>> $LOG_FILE
CHECK $? "daemon reloading"

systemctl enable payment    &>> $LOG_FILE
CHECK $? "enabling payment"

systemctl start payment   &>> $LOG_FILE
CHECK $? "starting payment"