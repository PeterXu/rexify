rex: management for server
==========================


rex usage
----------

create module:  
    a. rexify Service::NTP --create-module  
    b. lib/Service/NTP/files/etc/NTP.conf  
    c. rex -H yourserver01 Service:NTP:prepare  

```


for hagk project
----------------

```
    Service:sshkey:do     => config ssh public key
    Service:apt:do        => config apt source and docker source
    Service:docker:do     => install docker and config docker
    Service:pip:do        => install pip and config pip
    Service:hosts:do      => config /etc/hosts
    Service:softs:do
    Service:manual:do
```



