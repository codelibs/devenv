#!/bin/bash

cd `dirname $0`
cd ..
BASE_DIR=`pwd`

for JAR_FILE in `ls $BASE_DIR/../data/mecab-ipadic-neologd/lucene-analyzers-kuromoji-neologd-*.jar` ; do
    VERSION=`ls $JAR_FILE | sed -e "s/.*\/lucene-analyzers-kuromoji-neologd-\(.*\).jar/\1/"`
    mvn install:install-file -Dfile=$JAR_FILE -DgroupId=org.codelibs -DartifactId=lucene-analyzers-kuromoji-neologd -Dversion=$VERSION -Dpackaging=jar
done
