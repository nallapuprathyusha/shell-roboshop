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

dnf list installed redis -y  &>> $LOG_FILE
CHECK $? "checking availability for redis"

dnf module disable redis -y  &>> $LOG_FILE
CHECK $? "disabling redis"

dnf module enable redis:7 -y &>> $LOG_FILE
CHECK $? "enabling redis"

dnf install redis -y  &>> $LOG_FILE
CHECK $? "installing redis"

#sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
# sed -i -e 's/127.0.0.1/0.0.0.0 -e /protected-mode/c protected-mode no'/etc/redis/redis.conf &>>$log
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>> $LOG_FILE
CHECK $? "disabling redis"
validate $? "Redis Enabling Public Access"

sed -i '/protected-mode/c protected-mode no' /etc/redis/redis.conf &>> $LOG_FILE
CHECK $? "disabling redis"
validate $? "Protected Mode off"


systemctl enable redis  &>> $LOG_FILE
CHECK $? "Enabling redis"

systemctl start redis  &>> $LOG_FILE
CHECK $? "Starting redis"