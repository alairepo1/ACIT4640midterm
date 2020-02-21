#!/bin/bash

install(){
    # upgrades yum and installs git, nodejs, mongodb
    echo "Installing packages for midterm"
    ssh midterm "sudo yum install git -y"
    ssh midterm "sudo yum install nodejs -y"
    ssh midterm "sudo yum install mongodb-server -y"
    ssh midterm "sudo systemctl enable mongod && sudo systemctl start mongod"
    ssh midterm "sudo yum install nginx -y"
    scp -r ./files midterm:~
    echo "done"
}

create_user(){
    # Creates a new user and sets the password
    echo "creating hichat user"
    ssh midterm "sudo useradd hichat"
    ssh midterm "echo hichat:disabled | sudo chpasswd"
    echo "done"
}

get_app(){
    # makes a directory for the git app and clones the repo inside
    echo "cloning app repo"
    ssh midterm "sudo mkdir /home/hichat/app"
    ssh midterm "sudo git clone https://github.com/wayou/HiChat /home/hichat/app/"
}

move_setup (){
    ssh midterm "sudo rm /etc/nginx/nginx.conf"
    ssh midterm "sudo cp ~/files/hichat.service /etc/systemd/system/"
    ssh midterm "sudo cp ~/files/nginx.conf /etc/nginx/"
}

change_permissions(){
    # Change ownership and permissions of midterm dhichaty
    ssh midterm "sudo chown -R hichat /home/hichat"
    ssh midterm "sudo chmod 755 -R /home/hichat"
}

npm_install(){
    # installs node modules in app directory
    ssh midterm "(cd /home/hichat/app/ && sudo npm install)"
}

service_start() {
    ssh midterm "sudo systemctl daemon-reload"
    ssh midterm "sudo systemctl start nginx"
    ssh midterm "sudo systemctl enable nginx"
    ssh midterm "sudo systemctl start hichat"
    ssh midterm "sudo systemctl enable hichat"
}

# install
# create_user
# get_app
move_setup
change_permissions
npm_install
service_start