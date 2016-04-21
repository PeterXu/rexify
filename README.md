rex: management for server
==========================


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
rex -u peter Config:ubase:do --mod=fdisk --mountpoint="/mnt/nshare" --ondisk=sdc --fstype=ext4 --label="sdc_label"

##### git dockerfile by run
```
cat > /tmp/git_dockerfile.sh <<EOF
dfile="~/.dockerfile"
if [ -d $dfile ]; then
    cd $dfile && git pull
else
    rm -rf $dfile
    uri="http://lark.io:10080/itools/dockerfile.git"
    git clone $uri $dfile
fi

EOF
```
rex -u peter Config:ubase:do --mod=run --cmd="@/tmp/git_dockerfile.sh" --echo=yes


