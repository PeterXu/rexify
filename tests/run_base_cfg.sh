#!/usr/bin/env bash

[ $# -ne 1 ] && exit 1
grp="$1"
ruser="$RUSER"
[ "$grp" = "" -o "$ruser" = "" ] && exit 1


echo "=========================="
echo "[sshkey]"
rex -G $grp Service:sshkey:prepare

echo "=========================="
echo "[apt]"
rex -G $grp Service:apt:prepare

echo "=========================="
echo "[docker]"
rex -G $grp Service:docker:prepare --reload=all

echo "=========================="
echo "[pip]"
rex -G $grp Service:pip:prepare
#rex -G $grp Service:hosts:prepare

echo "=========================="
echo "[pull dockerfile]"
cmd="git clone https://github.com/peterxu/docker.git ~/.dockerfile"
rex -G $grp Service:manual:custom --by=run --cmd="$cmd"

echo "=========================="
echo "[docker-compose]"
cmd="pip install docker-compose"
rex -G $grp Service:manual:custom --by=run --cmd="$cmd"

exit 0
