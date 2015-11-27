do_start() {
    local uri="https://github.com/peterxu/ztools.git";
    mkdir -p ~/bin && git clone $uri ~/bin/ztools;
    cd ~/bin/ztools && bash zero_setting.sh set;
}

