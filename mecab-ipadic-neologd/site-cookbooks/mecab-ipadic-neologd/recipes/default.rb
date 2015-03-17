ant_version = "1.9.4"
ant_file = "apache-ant-#{ant_version}-bin.tar.gz"
ant_url = "http://ftp.kddilabs.jp/infosystems/apache//ant/binaries/#{ant_file}"
mecab_version = "0.994"
mecab_file = "mecab-#{mecab_version}.tar.gz"
mecab_url = "http://mecab.googlecode.com/files/#{mecab_file}"
ipadic_version = "2.7.0-20070801"
ipadic_file = "mecab-ipadic-#{ipadic_version}.tar.gz"
ipadic_url = "http://mecab.googlecode.com/files/#{ipadic_file}"
neologd_git_url = "https://github.com/neologd/mecab-ipadic-neologd.git"
lucene_version = "4_10_3"
lucene_svn_url = "http://svn.apache.org/repos/asf/lucene/dev/tags/lucene_solr_#{lucene_version}"


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

bash "mysql_config" do
  user "vagrant"
  cwd "/home/vagrant"
  code <<-EOH
  export ANT_HOME=`pwd`/apache-ant-#{ant_version}
  export MECAB_HOME=`pwd`/mecab_home
  export NEOLOGD_HOME=`pwd`/mecab-ipadic-neologd
  export LUCENE_SRC_HOME=`pwd`/lucene_solr_#{lucene_version}

  export PATH=$ANT_HOME/bin:$PATH
  export PATH=$MECAB_HOME/bin:$PATH

  mkdir $MECAB_HOME

  tar zxvf /tmp/#{ant_file}
  tar zxvf /tmp/#{mecab_file}
  tar zxvf /tmp/#{ipadic_file}

  cd mecab-#{mecab_version}
  ./configure --prefix=$MECAB_HOME
  make
  make install
  cd ..

  cd mecab-ipadic-#{ipadic_version}
  ./configure --with-charset=utf-8
  make
  make install
  cd ..

  git clone #{neologd_git_url}
  cd mecab-ipadic-neologd
  ./bin/install-mecab-ipadic-neologd -y -n --max_baseform_length 15
  cd ..

  svn co #{lucene_svn_url}
  cd $LUCENE_SRC_HOME/lucene
  ant ivy-bootstrap
  ant compile

  cd analysis/kuromoji

  cp -Rp $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-* $LUCENE_SRC_HOME/lucene/build/analysis/kuromoji

  IPADIC_VERSION=`basename $NEOLOGD_HOME/build/mecab-ipadic-*-neologd-*`

  sed -i "s/mecab-ipadic-2.7.0-20070801/$IPADIC_VERSION/g" build.xml
  sed -i "s/euc-jp/utf-8/g" build.xml
  sed -i "s/, download-dict//g" build.xml
  sed -i "s/1g/2g/g" build.xml

  ant regenerate
  ant jar-core
  EOH
end

