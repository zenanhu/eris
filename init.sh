#!/bin/bash

function should_continue() {
    read -p "Continue (y/n)?" CONT
    if [[ "$CONT" == "y" || "$CONT" == "Y" ]]; then
        echo "Continue..."
    else
        echo "Exit"
        exit 1
    fi
}

function update_password() {
    passwd root
}
function enable_password_login() {
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    echo PasswordAuthentication yes >> /etc/ssh/sshd_config
    systemctl restart sshd
    update_password
}

function install_docker() {
    apt update
    apt remove -y docker docker-engine docker.io
    apt install -y docker.io
    apt install -y docker-compose
}
function install_pkg() {
    install_docker
    apt install -y tmux
}

function generate_ssh_key() {
    cd ~
    ssh-keygen -t rsa -b 4096 -C "zenan2048@gmail.com"
    cat ~/.ssh/id_rsa.pub
    should_continue
}

# Input new shadowsocks password
function input_ss_password() {
    if [[ -z "${SS_PASSWORD}" ]]; then
        read -s -p "Input new shadowsocks password or leave empty to use default:" PW
    else
        echo "SS_PASSWORD is already set."
        return 0
    fi
    echo
    if [ -z "$PW" ]; then
        echo "Shadowsocks will use the default password."
    else
        echo export SS_PASSWORD="$PW" >> ~/.bashrc
        export SS_PASSWORD="$PW"
        source ~/.bashrc
        echo $SS_PASSWORD
        if [ "$SS_PASSWORD" != "$PW" ]; then
            echo "SS_PASSWORD is not reloaded."
            exit 1
        fi
    fi
}

function init_repos() {
    cd ~
    mkdir workspace
    cd workspace
    git clone --depth 1 git@github.com:zenanhu/eris.git
    git clone --depth 1 git@github.com:zenanhu/mars.git 
    git clone --depth 1 git@github.com:YitingLiu/portfolio.git ./portfolio-yiting
}

function init_vim() {
    git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    curl -o ~/.vimrc https://raw.githubusercontent.com/zenanhu/pluto/master/vimrc
    vim +PluginInstall +qall
}

function start_docker() {
    cd ~/workspace/eris
    docker-compose stop
    docker-compose -f docker-compose-ss.yml up -d
    docker-compose -f docker-compose.yml up -d
}

#enable_password_login
generate_ssh_key
input_ss_password
install_pkg
init_repos
init_vim
start_docker

cd ~
