#!bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/shell-scripting"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )

LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log

mkdir -p  $LOG_FOLDER

#echo  $LOG_FILE
#tee -a <File_name> -  display output and stores in file
#&>> -<file_name> dont display the output ,just stores the output


if [ $USERID -ne 0 ]; then
    echo "your not root user please switch to root user" | tee -a $LOG_FILE
fi

CHECK()
{
    
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


cp /root/shell-roboshop/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
CHECK $? "copying rabbitmq repo file to repository"

dnf install rabbitmq-server -y &>>$LOG_FILE
CHECK $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
CHECK $? "enable rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
CHECK $? "starting rabbitmq"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
        rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
        CHECK $? "Adding Roboshop user"
    else 
        echo "user already exist..$Y skipping $N" | tee -a &>>$LOG_FILE
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
CHECK $? "Granting permission to roboshop user"