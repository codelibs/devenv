#!/bin/bash

SUSPEND=n
if [ x$1 = "xwait" ] ; then
    SUSPEND=y
fi

vagrant ssh -c "sudo /etc/init.d/elasticsearch stop"
rm ../data/elasticsearch/logs/elasticsearch-codelibs*
vagrant ssh -c "sudo ES_JAVA_OPTS=\"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=$SUSPEND\" /etc/init.d/elasticsearch start"

