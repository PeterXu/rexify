rex: management for server
==========================

step 1
------
    >Service:sshkey:do     => config ssh public key
    >
    >Service:apt:do        => config apt source and docker source
    >
    >Service:docker:do     => install docker and config docker
    >
    >Service:pip:do        => install pip and config pip
    >
    >Service:hosts:do      => config /etc/hosts

step 2
------
    Service:softs:do
    Service:manual:do
