#!/bin/bash

if [ x"$ant_version" = "x" ] ; then
  ant_version="1.9.7"
fi
if [ x"$mecab_version" = "x" ] ; then
  mecab_version="0.996"
fi
if [ x"$unidic_version" = "x" ] ; then
  unidic_version="2.1.2"
fi
if [ x"$lucene_version" = "x" ] ; then
  lucene_version="7.4.0"
fi
if [ x"$max_baseform_length" = "x" ] ; then
  max_baseform_length=15
fi

ant_file="apache-ant-${ant_version}-bin.tar.gz"
ant_url="http://maven.codelibs.org/archive/ant/${ant_version}/${ant_file}"
mecab_file="mecab-${mecab_version}.tar.gz"
mecab_url="http://maven.codelibs.org/archive/mecab/${mecab_file}"
unidic_file="unidic-mecab-${unidic_version}_src.zip"
unidic_url="http://maven.codelibs.org/archive/mecab/${unidic_file}"
lucene_git_url="https://github.com/apache/lucene-solr.git"
resource_process_file="/tmp/resouce_process.txt"
mecab_process_file="/tmp/mecab_process.txt"
unidic_process_file="/tmp/unidic_process.txt"
lucene_process_file="/tmp/lucene_process.txt"
kuromoji_process_file="/tmp/kuromoji_process.txt"

curl -o "/tmp/${ant_file}" "${ant_url}"
curl -o "/tmp/${mecab_file}" "${mecab_url}"
curl -o "/tmp/${unidic_file}" "${unidic_url}"

setup_resources() {
  export MECAB_HOME=`pwd`/mecab_home

  mkdir $MECAB_HOME

  tar zxvf /tmp/${ant_file}
  tar zxvf /tmp/${mecab_file}
  unzip /tmp/${unidic_file}
}

mecab_build() {
  export MECAB_HOME=`pwd`/mecab_home
  export PATH=$MECAB_HOME/bin:$PATH

  pushd mecab-${mecab_version}
  ./configure --prefix=$MECAB_HOME
  make
  make install
  popd
}

unidic_build() {
  export MECAB_HOME=`pwd`/mecab_home
  export PATH=$MECAB_HOME/bin:$PATH
  export UNIDIC_HOME=`pwd`/unidic-mecab-${unidic_version}_src

  pushd $UNIDIC_HOME
  ./configure
  make
  make install
  popd
}

lucene_build() {
  export ANT_HOME=`pwd`/apache-ant-${ant_version}
  export LUCENE_SRC_HOME=`pwd`/lucene-solr

  export PATH=$ANT_HOME/bin:$PATH

  rm -rf $LUCENE_SRC_HOME
  git clone ${lucene_git_url}
  pushd $LUCENE_SRC_HOME
  git checkout -b ${lucene_version} refs/tags/releases/lucene-solr/${lucene_version}
  patch -p1 < /work/unidic.patch
  cd lucene
  ant ivy-bootstrap
  ant compile
  popd
}

kuromoji_build() {
  export ANT_HOME=`pwd`/apache-ant-${ant_version}
  export MECAB_HOME=`pwd`/mecab_home
  export LUCENE_SRC_HOME=`pwd`/lucene-solr
  export UNIDIC_HOME=`pwd`/unidic-mecab-${unidic_version}_src

  export PATH=$ANT_HOME/bin:$PATH
  export PATH=$MECAB_HOME/bin:$PATH

  pushd $LUCENE_SRC_HOME/lucene/analysis/kuromoji
  ant clean
  rm -rf src/ build.xml
  git checkout -- .
  pushd $LUCENE_SRC_HOME
  patch -p1 < /work/unidic.patch
  popd

  mkdir -p $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji
  cp -r $UNIDIC_HOME $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji

  UNIDIC_VERSION=`basename $UNIDIC_HOME`

  sed -i "s/mecab-ipadic-2.7.0-20070801/$UNIDIC_VERSION/g" build.xml
  sed -i "s/euc-jp/utf-8/g" build.xml
  sed -i "s/, download-dict//g" build.xml
  sed -i "s/1g/6g/g" build.xml
  sed -i "s/ipadic/unidic/g" build.xml
  sed -i "s/org\\/apache\\/lucene\\/analysis\\/ja/org\\/codelibs\\/unidic\\/lucene\\/analysis\\/ja/g" build.xml
  perl -pi -e "s/org\\.apache\\.lucene\\.analysis\\.ja/org.codelibs.unidic.lucene.analysis.ja/g" `find . -type f | grep -v /\.git/`
  mkdir -p src/resources/org/codelibs
  mv src/resources/org/apache src/resources/org/codelibs/unidic
  rm `find src/ -type f|grep package-info.java`

  ant regenerate
  if [ $? != 0 ] ; then exit 1;fi
  ant jar-core
  if [ $? != 0 ] ; then exit 1;fi
  popd
}

kuromoji_deploy() {
  export MECAB_HOME=`pwd`/mecab_home
  export LUCENE_SRC_HOME=`pwd`/lucene-solr

  JAR_VERSION=`echo $unidic_version | sed -e "s/\./_/g"`
  LUCENE_JAR=`basename $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar |sed -e "s/-SNAPSHOT//" -e "s/\\.jar/-${JAR_VERSION}.jar/" -e "s/analyzers-kuromoji/analyzers-kuromoji-unidic/"`
  cp $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar /data/mecab-unidic/$LUCENE_JAR
}

setup_resources
mecab_build
unidic_build
neologd_build
lucene_build
kuromoji_build
kuromoji_deploy
