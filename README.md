rex: management for server
==========================

step 1
------
    >Service:sshkey:prepare     => config ssh public key
    >
    >Service:apt:prepare        => config apt source and docker source
    >
    >Service:docker:prepare     => install docker and config docker
    >
    >Service:pip:prepare         => install pip and config pip
    >
    >Service:hosts:prepare       => config /etc/hosts

step 2
------
    Service:softs:install
    Service:manual:custom
