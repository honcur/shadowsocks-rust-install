

## 安装启动
###  a. 一键脚本安装
#安装/更新

```
source <(curl -sL https://raw.githubusercontent.com/honcur/shadowsocks-rust-install/main/install.sh)

```
### b.更改密码
将/usr/local/ss/config.josn文件中password值更改成你设置的密码.

###  c. 启动

启动服务: `systemctl start ss-rust`   

设置自启动: `systemctl enable ss-rust`

## 注意
安装完shadowsocks后强烈建议开启BBR等加速: [Linux-NetSpeed](https://github.com/chiakge/Linux-NetSpeed)  

journalctl -t ssserver -f
## Thanks
