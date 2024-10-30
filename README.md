# tools

# Docker Install (Docker Compose & JDK)
```
apt update && apt install -y git wget sudo \
&& cd /root && git clone https://github.com/cfd2022/tools.git \
&& cd /root/tools/docker/ && chmod +x ./install.sh && ./install.sh && apt autoremove -y
```



# Docker MySQL Backup(In Host)
```
wget https://raw.githubusercontent.com/cfd2022/tools/master/mysql/backup.sh
sudo chmod +x backup.sh && sudo ./backup.sh
```
```
wget https://raw.githubusercontent.com/cfd2022/tools/master/mysql/restore.sh
sudo chmod +x restore.sh && sudo ./restore.sh
```


# Glider SOCKS5
```
apt update && apt install -y git wget sudo
wget https://raw.githubusercontent.com/cfd2022/tools/main/glider/install_glider.sh
sudo chmod +x install_glider.sh && sudo ./install_glider.sh
```


# Mount RemoteServer as LocalDisk
```
apt update && apt install -y git wget sudo
wget https://raw.githubusercontent.com/cfd2022/tools/refs/heads/main/mysql/mount_remote_server_as_disk.sh
sudo chmod +x mount_remote_server_as_disk.sh && sudo ./mount_remote_server_as_disk.sh
```
