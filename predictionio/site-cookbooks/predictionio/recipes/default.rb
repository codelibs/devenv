version = '0.11.0-v1-SNAPSHOT'

case node['platform']
when "ubuntu", "debian"
  filename = "predictionio_#{version}_all.deb"
  remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

  remote_file "/tmp/#{filename}" do
   source "#{remote_uri}"
   mode 00644
  end

  package "predictionio" do
   action :install
   source "/tmp/#{filename}"
   options "--force-depends"
   provider Chef::Provider::Package::Dpkg
  end
when "centos", "redhat"
  version.gsub!(/-/, '_')
  filename = "predictionio-#{version}-1.noarch.rpm"
  remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

  remote_file "/tmp/#{filename}" do
   source "#{remote_uri}"
   mode 00644
  end

  package "predictionio" do
   action :install
   source "/tmp/#{filename}"
   options "--nodeps"
   provider Chef::Provider::Package::Rpm
  end
end

bash "update_config" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  sed -i "s#^SPARK_HOME=.*#SPARK_HOME=/opt/spark#" /etc/predictionio/pio-env.sh
  sed -i "s/^PIO_STORAGE_REPOSITORIES_METADATA_SOURCE=.*/PIO_STORAGE_REPOSITORIES_METADATA_SOURCE=ELASTICSEARCH/" /etc/predictionio/pio-env.sh
  sed -i "s/^PIO_STORAGE_REPOSITORIES_EVENTDATA_SOURCE=.*/PIO_STORAGE_REPOSITORIES_EVENTDATA_SOURCE=ELASTICSEARCH/" /etc/predictionio/pio-env.sh
  sed -i "s/^PIO_STORAGE_REPOSITORIES_MODELDATA_SOURCE=.*/PIO_STORAGE_REPOSITORIES_MODELDATA_SOURCE=LOCALFS/" /etc/predictionio/pio-env.sh

  sed -i "s/.*PIO_STORAGE_SOURCES_ELASTICSEARCH_TYPE=.*/PIO_STORAGE_SOURCES_ELASTICSEARCH_TYPE=elasticsearch/" /etc/predictionio/pio-env.sh
  sed -i "s/.*PIO_STORAGE_SOURCES_ELASTICSEARCH_HOSTS=.*/PIO_STORAGE_SOURCES_ELASTICSEARCH_HOSTS=localhost/" /etc/predictionio/pio-env.sh
  sed -i "s/.*PIO_STORAGE_SOURCES_ELASTICSEARCH_PORTS=.*/PIO_STORAGE_SOURCES_ELASTICSEARCH_PORTS=9200/" /etc/predictionio/pio-env.sh
  sed -i "s/.*PIO_STORAGE_SOURCES_ELASTICSEARCH_SCHEMES=.*/PIO_STORAGE_SOURCES_ELASTICSEARCH_SCHEMES=http/" /etc/predictionio/pio-env.sh
  sed -i "s/.*PIO_STORAGE_SOURCES_ELASTICSEARCH_HOME=.*/PIO_STORAGE_SOURCES_ELASTICSEARCH_HOME=\/usr\/share\/predictionio/" /etc/predictionio/pio-env.sh

  sed -i "s/.*PIO_STORAGE_SOURCES_LOCALFS_TYPE=.*/PIO_STORAGE_SOURCES_LOCALFS_TYPE=localfs/" /etc/predictionio/pio-env.sh
  sed -i 's#.*PIO_STORAGE_SOURCES_LOCALFS_PATH=.*#PIO_STORAGE_SOURCES_LOCALFS_PATH=$PIO_FS_BASEDIR/models#' /etc/predictionio/pio-env.sh
  EOH
end
