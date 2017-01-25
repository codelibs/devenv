es_version = "2.4.4"

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

case node['platform']
when "ubuntu", "debian"
  filename = "elasticsearch-#{es_version}.deb"
  remote_uri = "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/#{es_version}/#{filename}"

  remote_file "/tmp/#{filename}" do
      source "#{remote_uri}"
      mode 00644
  end

  package "elasticsearch" do
      action :install
      source "/tmp/#{filename}"
      provider Chef::Provider::Package::Dpkg
  end
when "centos", "redhat"
  filename = "elasticsearch-#{es_version}.rpm"
  remote_uri = "https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/#{es_version}/#{filename}"

  remote_file "/tmp/#{filename}" do
      source "#{remote_uri}"
      mode 00644
  end

  package "elasticsearch" do
      action :install
      source "/tmp/#{filename}"
      provider Chef::Provider::Package::Rpm
  end
end

bash "update_es_yml" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  cat /etc/elasticsearch/elasticsearch.yml > /tmp/elasticsearch.yml.tmp
  echo "cluster.name: elasticsearch" >> /tmp/elasticsearch.yml.tmp
  echo "node.name: \"ES Node 1\"" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_shards: 1" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_replicas: 0" >> /tmp/elasticsearch.yml.tmp
  echo "http.cors.enabled: true" >> /tmp/elasticsearch.yml.tmp
  echo 'http.cors.allow-origin: "*"' >> /tmp/elasticsearch.yml.tmp
  echo 'network.host: "0"' >> /tmp/elasticsearch.yml.tmp
  echo "configsync.config_path: /var/lib/elasticsearch/config" >> /tmp/elasticsearch.yml.tmp
  echo "script.engine.groovy.inline.update: on" >> /tmp/elasticsearch.yml.tmp
  mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
  sed -e "s/es.logger.level: INFO/es.logger.level: DEBUG/" /etc/elasticsearch/logging.yml > /tmp/logging.yml.tmp
  mv -f /tmp/logging.yml.tmp /etc/elasticsearch/logging.yml
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

bash "install_plugins" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-fess/2.4.0 -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-ja/2.4.0 -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-synonym/2.4.0 -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-configsync/2.4.2 -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-dataformat/2.4.0 -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-langfield/2.4.1 -b
  /usr/share/elasticsearch/bin/plugin install http://maven.codelibs.org/archive/elasticsearch/plugin/kopf/elasticsearch-kopf-2.0.1.0.zip -b
  /usr/share/elasticsearch/bin/plugin install org.codelibs/elasticsearch-analysis-kuromoji-neologd/2.4.1 -b
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

