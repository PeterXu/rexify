#!/usr/bin/env bash

[ $# -ne 1 ] && exit 1
grp="$1"
ruser="$RUSER"
[ "$grp" = "" -o "$ruser" = "" ] && exit 1


echo "=========================="
echo "[sshkey]"
rex -G $grp Service:sshkey:do

echo "=========================="
echo "[apt]"
rex -G $grp Service:apt:do

echo "=========================="
echo "[docker]"
rex -G $grp Service:docker:do --reload=all

echo "=========================="
echo "[pip]"
rex -G $grp Service:pip:do
#rex -G $grp Service:hosts:do

echo "=========================="
echo "[pull dockerfile]"
cmd="git clone https://github.com/peterxu/docker.git ~/.dockerfile"
rex -G $grp Service:manual:do --by=run --cmd="$cmd"

echo "=========================="
echo "[docker-compose]"
cmd="pip install docker-compose"
rex -G $grp Service:manual:do --by=run --cmd="$cmd"

exit 0
