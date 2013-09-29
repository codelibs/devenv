#!/bin/bash

SUSPEND=n
if [ x$1 = "xwait" ] ; then
    SUSPEND=y
fi

vagrant ssh -c "sudo /etc/init.d/fess stop"
vagrant ssh -c "sudo JAVA_OPTS=\"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=$SUSPEND\" /etc/init.d/fess start"

