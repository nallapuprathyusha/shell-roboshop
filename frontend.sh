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

dnf list installed nginx
CHECK $? "checking for nginx"

dnf module disable nginx -y
CHECK $? "disabling nginx"

dnf module enable nginx:1.24 -y
CHECK $? "enabling for nginx"

dnf install nginx -y
CHECK $? "installing nginx"


