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
rex -H localhost -u peter Config:ubase:do

##### ssh, /etc/hosts and etc.
rex -H localhost -u peter Config:ubase:do_mod --mod=sshkey
rex -H localhost -u peter Config:ubase:do_mod --mod=sshd
rex -H localhost -u peter Config:ubase:do_mod --mod=hosts [--cleanonly=yes]
rex -H localhost -u peter Config:ubase:do_mod --mod=chown --path=filename [--owner=.. --group=..]
rex -H localhost -u peter Config:ubase:do_mod --mod=upload --src=src.txt --dst=dst.txt

##### install soft direct or from file
rex -H localhost -u peter Config:ubase:do_mod --mod=softs --list=sl,unzip
rex -H localhost -u peter Config:ubase:do_mod --mod=softs --list="@/tmp/pkg.txt"


##### fdisk
rex -H localhost -u peter Config:ubase:do_mod --mod=fdisk --mountpoint="/mnt/nshare" --ondisk=sdc --fstype=ext4 --label="sdc_label"

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
rex -H localhost Config:ubase:do_mod --mod=run --cmd="@/tmp/git_dockerfile.sh" --echo=yes


