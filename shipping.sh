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

dnf install maven -y
CHECK $? "installing maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    CHECK $? "Adding Application user"
else
    echo "User already exist"

fi

mkdir  -p /app &>>$LOG_FILE
CHECK $? "creating app directory"

rm -rf app/* &>>$LOG_FILE
CHECK $? "removing old files in app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
CHECK $? "downloading files"

cd /app &>>$LOG_FILE
CHECK $? "moving to app directory" 

unzip /tmp/shipping.zip &>>$LOG_FILE
CHECK $? "unziping the files"

mvn clean package &>>$LOG_FILE
CHECK $? "generating bulid file"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
CHECK $? "moving bulid file"

cp /root/shell-roboshop/shipping.service /etc/systemd/system/shipping.service
CHECK $? "creating shipping services"

systemctl daemon-reload &>>$LOG_FILE
CHECK $? "daemon reload"

dnf install mysql -y &>>$LOG_FILE
CHECK $? "installing mysql client"

mysql -h mysql.prathyusha.fun -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
CHECK $? "Loading Schema"


mysql -h mysql.prathyusha.fun -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
CHECK $? "Loading App User data"

mysql -h mysql.prathyusha.fun -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
CHECK $? "Loading Master data"


systemctl restart shipping &>>$LOG_FILE
CHECK $? "restarting shipping"