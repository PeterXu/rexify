rex: management for server
==========================


rex install
-----------

### 1. common install
    curl -L https://get.rexify.org | perl - --sudo -n Rex

### 2. for ubuntu 14.04
    echo 'deb http://rex.linux-files.org/ubuntu/ trusty rex' >/etc/apt/sources.list.d/rex.list
    apt-get update
    apt-get install rex=1.4.0-1


rex usage
----------

create module:  
    a. rexify Service::NTP --create-module  
    b. lib/Service/NTP/files/etc/NTP.conf  
    c. rex -H yourserver01 Service:NTP:prepare  


rex in practice
---------------

##### init system
rex -u peter Config:ubase:do --mod=init

##### ssh, /etc/hosts and etc.
rex -H localhost -u peter Config:ubase:do --mod=hosts [--cleanonly=yes]
rex -u peter Config:ubase:do --mod=sshkey
rex -u peter Config:ubase:do --mod=sshd
rex -u peter Config:ubase:do --mod=chown --path=filename [--owner=.. --group=..]
rex -u peter Config:ubase:do --mod=upload --src=src.txt --dst=dst.txt

##### update config
rex -u peter Config:ubase:do --mod=sed --file=/tmp/test.conf --search="^port = .*" --replace="port = 80"

##### install soft direct or from file
rex -u peter Config:ubase:do --mod=softs --list=sl,unzip
rex -u peter Config:ubase:do --mod=softs --list="@/tmp/pkg.txt"


##### fdisk
rex -u peter Config:ubase:do --mod=fdisk --mountpoint="/mnt/share" --ondisk=sdc --fstype=ext4 --label="sdc_label"

##### git dockerfile by run
```
git clone http://lark.io:10080/itools/dockerfile.git /home/soccerdojo/.dockerfile"
cd /home/soccerdojo/.dockerfile && git pull
```
rex -u peter Config:ubase:do --mod=run --cmd="@/tmp/git_dockerfile.sh" --echo=yes


##### gluster 
rex -u peter Config:ubase:do --mod=gluster_client --dockerimg="lark.io/gluster:stable"
rex -u peter Config:ubase:do --mod=gluster_mount --mountpoint=/mnt/nshare --volname=/dist_repl_vol --entryhost=127.0.0.1


