#!/bin/bash
./detect.sh
source prometheus-hosts

#针对所有prometheus-hosts里面的主机做免密登陆
for i in `grep '=' prometheus-hosts | cut -d "=" -f2`
do
sshpass -p1 ssh-copy-id $i &>>/dev/null
done

#传送prometheus的包
tar xf prometheus-2.20.1.linux-amd64.tar.gz
mv prometheus-2.20.1.linux-amd64 prometheus
scp -r prometheus root@$prometheus:/usr/local/bin &>>/dev/null

#传送prometheus的服务文件
scp prometheus.service root@$prometheus:/etc/systemd/system/ &>>/dev/null

ssh root@$prometheus systemctl daemon-reload 
ssh root@$prometheus systemctl disable fireawlld --now &>>/dev/null
ssh root@$prometheus 'sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config'
ssh root@$prometheus setenforce 0

tar xf node_exporter-1.0.1.linux-amd64.tar.gz
mv node_exporter-1.0.1.linux-amd64 node_exporter

for i in `grep 'node' prometheus-hosts | cut -d "=" -f2`
do
scp -r node_exporter root@$i:/usr/local/bin &>>/dev/null
scp node_exporter.service root@$i:/etc/systemd/system/ &>>/dev/null
ssh root@$i systemctl daemon-reload
ssh root@$prometheus 'echo    "    - targets: ['$i:9100']" >> /usr/local/bin/prometheus/prometheus.yml'
ssh root@$i systemctl enable node_exporter --now &>>/dev/null
ssh root@$i systemctl disable firewalld --now &>>/dev/null
ssh root@$i 'sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config'
ssh root@$i setenforce 0
done
rm -rf node_exporter prometheus
ssh root@$prometheus systemctl enable prometheus --now &>>/dev/null


