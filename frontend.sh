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

dnf list installed nginx
CHECK $? "checking for nginx"

dnf module disable nginx -y &>>$LOG_FILE
CHECK $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
CHECK $? "enabling for nginx"

dnf install nginx -y &>>$LOG_FILE
CHECK $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
CHECK $? "enabling nginx"

systemctl start nginx &>>$LOG_FILE
CHECK $? "starting nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
CHECK $? "Downloading frontend"

cp /root/shell-roboshop/nginx.conf /etc/nginx/nginx.conf
CHECK $? "copying conf files"

systemctl restart nginx 
CHECK $? "restarting nginx"

