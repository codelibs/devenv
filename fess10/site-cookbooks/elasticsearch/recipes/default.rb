es_version = "2.1.2"
filename = "elasticsearch-#{es_version}.rpm"
remote_uri = "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/#{es_version}/#{filename}"

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{filename}" do
    source "#{remote_uri}"
    mode 00644
end

package "elasticsearch" do
    action :install
    source "/tmp/#{filename}"
    provider Chef::Provider::Package::Rpm
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
  mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
  sed -e "s/es.logger.level: INFO/es.logger.level: DEBUG/" /etc/elasticsearch/logging.yml > /tmp/logging.yml.tmp
  mv -f /tmp/logging.yml.tmp /etc/elasticsearch/logging.yml
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end
