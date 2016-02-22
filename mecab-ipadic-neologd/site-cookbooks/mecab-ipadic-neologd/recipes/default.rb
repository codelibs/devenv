ant_version = "1.9.6"
ant_file = "apache-ant-#{ant_version}-bin.tar.gz"
ant_url = "http://ftp.kddilabs.jp/infosystems/apache/ant/binaries/#{ant_file}"
mecab_version = "0.994"
mecab_file = "mecab-#{mecab_version}.tar.gz"
mecab_url = "http://mecab.googlecode.com/files/#{mecab_file}"
ipadic_version = "2.7.0-20070801"
ipadic_file = "mecab-ipadic-#{ipadic_version}.tar.gz"
ipadic_url = "http://mecab.googlecode.com/files/#{ipadic_file}"
neologd_git_url = "https://github.com/neologd/mecab-ipadic-neologd.git"
lucene_version = "4_10_4"
# lucene_version = "5_2_1"
lucene_svn_url = "http://svn.apache.org/repos/asf/lucene/dev/tags/lucene_solr_#{lucene_version}"
resource_process_file = "/tmp/resouce_process.txt"
mecab_process_file = "/tmp/mecab_process.txt"
ipadic_process_file = "/tmp/ipadic_process.txt"
neologd_process_file = "/tmp/neologd_process.txt"
lucene_process_file = "/tmp/lucene_process.txt"
kuromoji_process_file = "/tmp/kuromoji_process.txt"
max_baseform_length = 15

remote_file "/tmp/#{ant_file}" do
    source "#{ant_url}"
    mode 00644
end

remote_file "/tmp/#{mecab_file}" do
    source "#{mecab_url}"
    mode 00644
end

remote_file "/tmp/#{ipadic_file}" do
    source "#{ipadic_url}"
    mode 00644
end

execute "devtools" do
   user "root"
   command 'yum -y groupinstall "Development Tools"'
   action :run
end

%w{
  git
  subversion
}.each do |pkgname|
    package "#{pkgname}" do
      action :install
    end
end

bash "setup-resources" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export MECAB_HOME=`pwd`/mecab_home

  mkdir $MECAB_HOME

  tar zxvf /tmp/#{ant_file}
  tar zxvf /tmp/#{mecab_file}
  tar zxvf /tmp/#{ipadic_file}

  touch #{resource_process_file}
  EOH
  only_if { ! ::File.exists?(resource_process_file) }
end

bash "mecab-build" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export MECAB_HOME=`pwd`/mecab_home
  export PATH=$MECAB_HOME/bin:$PATH

  cd mecab-#{mecab_version}
  ./configure --prefix=$MECAB_HOME
  make
  make install

  touch #{mecab_process_file}
  EOH
  only_if { ! ::File.exists?(mecab_process_file) }
end

bash "ipadic-build" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export MECAB_HOME=`pwd`/mecab_home
  export PATH=$MECAB_HOME/bin:$PATH

  cd mecab-ipadic-#{ipadic_version}
  ./configure --with-charset=utf-8
  make
  make install

  touch #{ipadic_process_file}
  EOH
  only_if { ! ::File.exists?(ipadic_process_file) }
end

bash "neologd-build" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export PATH=$MECAB_HOME/bin:$PATH

  rm -rf mecab-ipadic-neologd
  git clone #{neologd_git_url}
  cd mecab-ipadic-neologd

  export SEED_XZ_FILE=`ls ./seed/mecab-user-dict-seed.*`
  export SEED_CSV_FILE=`echo $SEED_XZ_FILE | sed -e 's/.xz$//'`
  xz -cd $SEED_XZ_FILE \
    | grep -v "^警備員,.*,アンチスキル.*" \
    | grep -v "^風紀委員,.*,ジャッジメント.*" \
    | grep -v "^一方通行,.*,アクセラレータ.*" \
    > $SEED_CSV_FILE
  rm $SEED_XZ_FILE
  xz $SEED_CSV_FILE

  ./bin/install-mecab-ipadic-neologd -y -n --max_baseform_length #{max_baseform_length}

  touch #{neologd_process_file}
  EOH
  only_if { ! ::File.exists?(neologd_process_file) }
end

bash "lucene-build" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export ANT_HOME=`pwd`/apache-ant-#{ant_version}
  export LUCENE_SRC_HOME=`pwd`/lucene_solr_#{lucene_version}

  export PATH=$ANT_HOME/bin:$PATH

  rm -rf $LUCENE_SRC_HOME
  svn co #{lucene_svn_url}
  cd $LUCENE_SRC_HOME/lucene
  ant ivy-bootstrap
  ant compile

  rm #{kuromoji_process_file}
  touch #{lucene_process_file}
  EOH
  only_if { ! ::File.exists?(lucene_process_file) }
end

bash "kuromoji-build" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export ANT_HOME=`pwd`/apache-ant-#{ant_version}
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export LUCENE_SRC_HOME=`pwd`/lucene_solr_#{lucene_version}

  export PATH=$ANT_HOME/bin:$PATH
  export PATH=$MECAB_HOME/bin:$PATH

  cd $LUCENE_SRC_HOME/lucene/analysis/kuromoji
  ant clean
  rm -rf src/ build.xml
  svn update

  mkdir -p $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji
  DICT_DIR=`ls -d $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-*`
  cp -r $DICT_DIR $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji

  IPADIC_VERSION=`basename $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-*`

  sed -i "s/mecab-ipadic-2.7.0-20070801/$IPADIC_VERSION/g" build.xml
  sed -i "s/euc-jp/utf-8/g" build.xml
  sed -i "s/, download-dict//g" build.xml
  sed -i "s/1g/4g/g" build.xml
  sed -i "s/org\\/apache\\/lucene\\/analysis\\/ja/org\\/codelibs\\/neologd\\/ipadic\\/lucene\\/analysis\\/ja/g" build.xml
  perl -pi -e "s/org\\.apache\\.lucene\\.analysis\\.ja/org.codelibs.neologd.ipadic.lucene.analysis.ja/g" `find . -type f | grep -v /\.svn/`
  mkdir -p src/resources/org/codelibs/neologd
  mv src/resources/org/apache src/resources/org/codelibs/neologd/ipadic

  ant regenerate
  if [ $? != 0 ] ; then exit 1;fi
  ant jar-core
  if [ $? != 0 ] ; then exit 1;fi

  touch #{kuromoji_process_file}
  EOH
  only_if { ! ::File.exists?(kuromoji_process_file) }
end

bash "kuromoji-deploy" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export LUCENE_SRC_HOME=`pwd`/lucene_solr_#{lucene_version}

  NEOLOGD_VERSION=`echo $NEOLOGD_HOME/seed/mecab-user-dict-seed.*.csv.xz | sed -e "s/.*seed\\.//" -e "s/.csv.xz//"`
  NEOLOGD_LUCENE_JAR=`basename $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar |sed -e "s/-SNAPSHOT//" -e "s/\\.jar/-${NEOLOGD_VERSION}.jar/" -e "s/analyzers-kuromoji/analyzers-kuromoji-ipadic-neologd/"`
  cp $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji/lucene-analyzers-kuromoji-*.jar /opt/mecab-ipadic-neologd/$NEOLOGD_LUCENE_JAR
  EOH
end
