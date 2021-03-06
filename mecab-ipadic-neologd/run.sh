#!/bin/bash

if [ x"$ant_version" = "x" ] ; then
  ant_version="1.9.7"
fi
if [ x"$mecab_version" = "x" ] ; then
  mecab_version="0.996"
fi
if [ x"$ipadic_version" = "x" ] ; then
  ipadic_version="2.7.0-20070801"
fi
if [ x"$lucene_version" = "x" ] ; then
  lucene_version="7.4.0"
fi
if [ x"$max_baseform_length" = "x" ] ; then
  max_baseform_length=15
fi

ant_file="apache-ant-${ant_version}-bin.tar.gz"
ant_url="https://maven.codelibs.org/archive/ant/${ant_version}/${ant_file}"
mecab_file="mecab-${mecab_version}.tar.gz"
mecab_url="https://maven.codelibs.org/archive/mecab/${mecab_file}"
ipadic_file="mecab-ipadic-${ipadic_version}.tar.gz"
ipadic_url="https://maven.codelibs.org/archive/mecab/${ipadic_file}"
neologd_git_url="https://github.com/neologd/mecab-ipadic-neologd.git"
lucene_git_url="https://github.com/apache/lucene-solr.git"
resource_process_file="/tmp/resouce_process.txt"
mecab_process_file="/tmp/mecab_process.txt"
ipadic_process_file="/tmp/ipadic_process.txt"
neologd_process_file="/tmp/neologd_process.txt"
lucene_process_file="/tmp/lucene_process.txt"
kuromoji_process_file="/tmp/kuromoji_process.txt"

curl -o "/tmp/${ant_file}" "${ant_url}"
curl -o "/tmp/${mecab_file}" "${mecab_url}"
curl -o "/tmp/${ipadic_file}" "${ipadic_url}"

setup_resources() {
  export MECAB_HOME=`pwd`/mecab_home

  mkdir $MECAB_HOME

  tar zxvf /tmp/${ant_file}
  tar zxvf /tmp/${mecab_file}
  tar zxvf /tmp/${ipadic_file}
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

ipadic_build() {
  export MECAB_HOME=`pwd`/mecab_home
  export PATH=$MECAB_HOME/bin:$PATH

  pushd mecab-ipadic-${ipadic_version}
  ./configure --with-charset=utf-8
  make
  make install
  popd
}

neologd_build() {
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export PATH=$MECAB_HOME/bin:$PATH

  rm -rf mecab-ipadic-neologd
  git clone ${neologd_git_url}
  pushd mecab-ipadic-neologd

  export SEED_XZ_FILE=`ls ./seed/mecab-user-dict-seed.* | tail -n1`
  export SEED_CSV_FILE=`echo $SEED_XZ_FILE | sed -e 's/.xz$//'`
  xz -cd $SEED_XZ_FILE \
    | grep -v "^警備員,.*,アンチスキル.*" \
    | grep -v "^風紀委員,.*,ジャッジメント.*" \
    | grep -v "^一方通行,.*,アクセラレータ.*" \
    > $SEED_CSV_FILE
  rm $SEED_XZ_FILE
  xz $SEED_CSV_FILE

  ./bin/install-mecab-ipadic-neologd -y -n --max_baseform_length ${max_baseform_length}
  popd
}

lucene_build() {
  export ANT_HOME=`pwd`/apache-ant-${ant_version}
  export LUCENE_SRC_HOME=`pwd`/lucene-solr

  export PATH=$ANT_HOME/bin:$PATH

  rm -rf $LUCENE_SRC_HOME
  git clone ${lucene_git_url}
  pushd $LUCENE_SRC_HOME
  if [ x"$lucene_commit" = "x" ] ; then
    git checkout -b ${lucene_version} refs/tags/releases/lucene-solr/${lucene_version}
  else
    git checkout -b ${lucene_version} ${lucene_commit}
  fi
  cd lucene
  ant ivy-bootstrap
  ant compile
  popd
}

kuromoji_build() {
  export ANT_HOME=`pwd`/apache-ant-${ant_version}
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export LUCENE_SRC_HOME=`pwd`/lucene-solr

  export PATH=$ANT_HOME/bin:$PATH
  export PATH=$MECAB_HOME/bin:$PATH

  pushd $LUCENE_SRC_HOME/lucene/analysis/kuromoji
  ant clean
  rm -rf src/ build.xml
  git checkout -- .

  mkdir -p $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji
  DICT_DIR=`ls -d $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-*`
  cp -r $DICT_DIR $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji

  IPADIC_VERSION=`basename $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-*`

  sed -i "s/mecab-ipadic-2.7.0-20070801/$IPADIC_VERSION/g" build.xml
  sed -i "s/euc-jp/utf-8/g" build.xml
  sed -i "s/, download-dict//g" build.xml
  sed -i "s/1g/6g/g" build.xml
  sed -i "s/org\\/apache\\/lucene\\/analysis\\/ja/org\\/codelibs\\/neologd\\/ipadic\\/lucene\\/analysis\\/ja/g" build.xml
  perl -pi -e "s/org\\.apache\\.lucene\\.analysis\\.ja/org.codelibs.neologd.ipadic.lucene.analysis.ja/g" `find . -type f | grep -v /\.git/`
  mkdir -p src/resources/org/codelibs/neologd
  mv src/resources/org/apache src/resources/org/codelibs/neologd/ipadic
  rm `find src/ -type f|grep package-info.java`

  ant regenerate
  if [ $? != 0 ] ; then exit 1;fi
  ant jar-core
  if [ $? != 0 ] ; then exit 1;fi
  popd
}

kuromoji_deploy() {
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export LUCENE_SRC_HOME=`pwd`/lucene-solr

  NEOLOGD_VERSION=`echo $NEOLOGD_HOME/seed/mecab-user-dict-seed.*.csv.xz | sed -e "s/.*seed\\.//" -e "s/.csv.xz//"`
  NEOLOGD_LUCENE_JAR=`basename $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar |sed -e "s/-SNAPSHOT//" -e "s/\\.jar/-${NEOLOGD_VERSION}.jar/" -e "s/analyzers-kuromoji/analyzers-kuromoji-ipadic-neologd/"`
  cp $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar /data/mecab-ipadic-neologd/$NEOLOGD_LUCENE_JAR
}

setup_resources
mecab_build
ipadic_build
neologd_build
lucene_build
kuromoji_build
kuromoji_deploy
