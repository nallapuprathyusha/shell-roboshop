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


dnf list installed mongodb-org &>> $LOG_FILE
CHECK $? "Mongodb check"

#touch /etc/yum.repos.d/mongo.repo
cp /root/shell-roboshop/mongo.repo /etc/yum.repos.d
CHECK $? "copying mongo repo file to repository"

dnf install mongodb-org -y &>> $LOG_FILE
CHECK $? "mongo installed"

systemctl enable mongod &>> $LOG_FILE
CHECK $? "Enable MongoDB"


systemctl start mongod &>> $LOG_FILE
CHECK $? "mongo started"

#SED
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

systemctl restart mongod &>> $LOG_FILE
CHECK $? "restart mongod"