#!bin/bash

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo "your not root user please switch to root user"
fi


CHECK()
{
    
    if [ $? -ne 0 ]; then
        echo "$2 is failure" 
    else
        echo "$? is success"
    fi
}



dnf list installed mongodb-org
CHECK $? "Mongodb check"

cp /root/shell-roboshop/mongo.repo /etc/yum/respos.d/mongo.repo
CHECK $? "copying mongo repo file to repository"

dnf install mongodb-org -y
CHECK $? "mongo installed"

systemctl enable mongod
VALIDATE $? "Enable MongoDB"


systemctl start mongod 
CHECK $? "mongo started"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

systemctl daemon-reload
CHECK $? "daemon reload"