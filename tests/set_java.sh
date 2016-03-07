#!/bin/bash

java_sdk=./jdk1.8.0_45

if [ ! -d /usr/lib/jvm/java ]; then
    mkdir -p /usr/lib/jvm
    mv $java_sdk /usr/lib/jvm/java
fi

if cat /etc/profile | grep JAVA_HOME; then
    echo "OK"
else
    cat >> /etc/profile <<EOF

export JAVA_HOME=/usr/lib/jvm/java
export JRE_HOME=\${JAVA_HOME}/jre
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JRE_HOME}/lib
EOF
fi

if [ ! -f /usr/bin/java ]; then
    java=/usr/lib/jvm/java/bin/java
    [ -f $java ] && ln -s $java /usr/bin/java
fi

exit 0
