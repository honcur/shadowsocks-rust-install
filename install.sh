#!/bin/bash

#定义操作变量, 0为否, 1为是
remove=0

download_url="https://github.com/shadowsocks/shadowsocks-rust/releases/download/"
version_check="https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest"
service_url="https://raw.githubusercontent.com/honcur/shadowsocks-rust-install/main/ss-rust.service"
config_url="https://raw.githubusercontent.com/honcur/shadowsocks-rust-install/main/config.json"
#Centos 临时取消别名
[[ -f /etc/redhat-release && -z $(echo $SHELL|grep zsh) ]] && unalias -a

[[ -z $(echo $SHELL|grep zsh) ]] && shell_way="bash" || shell_way="zsh"

#######color code########
red="31m"
green="32m"
yellow="33m"
blue="36m"
fuchsia="35m"

colorEcho(){
    color=$1
    echo -e "\033[${color}${@:2}\033[0m"
}

#######get params#########
while [[ $# > 0 ]];do
    key="$1"
    case $key in
        --remove)
        remove=1
        ;;
        -h|--help)
        help=1
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

checkSys() {
    #检查是否为Root
    [ $(id -u) != "0" ] && { colorEcho ${red} "Error: You must be root to run this script"; exit 1; }

    arch=$(uname -m 2> /dev/null)
    if [[ $arch != x86_64 && $arch != aarch64 ]];then
        colorEcho $yellow "not support $arch machine".
        exit 1
    fi

    if [[ `command -v apt-get` ]];then
        package_manager='apt-get'
    elif [[ `command -v dnf` ]];then
        package_manager='dnf'
    elif [[ `command -v yum` ]];then
        package_manager='yum'
    else
        colorEcho $red "Not support OS!"
        exit 1
    fi

    # 缺失/usr/local/bin路径时自动添加
    [[ -z `echo $PATH|grep /usr/local/bin` ]] && { echo 'export PATH=$PATH:/usr/local/bin' >> /etc/bashrc; source /etc/bashrc; }
}
[[ -f /usr/local/ss ]] && update=1

installShadowsocks(){
    local show_tip=0
    if [[ $update == 1 ]];then
        systemctl stop ss-rust >/dev/null 2>&1
        rm -rf /usr/local/ss
    fi
    lastest_version=$(curl -H 'Cache-Control: no-cache' -s "$version_check" | grep 'tag_name' | cut -d\" -f4)
    echo "正在下载管理程序`colorEcho $blue $lastest_version`版本..."
    [[ $arch == x86_64 ]] && bin="shadowsocks-${lastest_version}.x86_64-unknown-linux-gnu.tar.xz" || bin="shadowsocks-${lastest_version}.arm-unknown-linux-gnu.tar.xz" 
    curl -L "$download_url/$lastest_version/$bin" -o /tmp
    mkdir -p /usr/local/ss
    tar xvf /tmp/$bin -C /usr/local/ss
    chmod -R +x /usr/local/ss
    if [[ ! -e /usr/local/ss/config.json ]];then
        show_tip=1
        curl -L $config_url -o /usr/local/ss/config.json
    fi
    if [[ ! -e /etc/systemd/system/ss-rust.service ]];then
        show_tip=1
        curl -L $service_url -o /etc/systemd/system/ss-rust.service
        systemctl daemon-reload
        systemctl enable ss-rust
    fi
    colorEcho $green "安装shadowsocks程序成功!\n"
}

removeShadowsocks() {
    rm -rf /usr/local/ss >/dev/null 2>&1
    rm -f /etc/systemd/system/ss-rust.service >/dev/null 2>&1
    systemctl daemon-reload
    colorEcho ${green} "uninstall success!"
}

main(){
    [[ ${remove} == 1 ]] && removeShadowsocks && return
    echo "正在安装shadowsocks-rust..." 
    checkSys
    installShadowsocks
}
main