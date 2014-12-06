filename = "elasticsearch-1.4.1.noarch.rpm"
#filename = "elasticsearch-1.3.5.noarch.rpm"
remote_uri = "https://download.elasticsearch.org/elasticsearch/elasticsearch/#{filename}"

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{filename}" do
    source "#{remote_uri}"
    mode 00644
end
#cookbook_file "/tmp/elasticsearch-0.90.5.noarch.rpm" do
#    source "elasticsearch-0.90.5.noarch.rpm"
#    mode 00644
#end

package "elasticsearch" do
    action :install
    source "/tmp/#{filename}"
    provider Chef::Provider::Package::Rpm
end

cookbook_file "/etc/elasticsearch/mapping_ja.txt" do
    mode 00644
end

cookbook_file "/etc/elasticsearch/stopwords_ja.txt" do
    mode 00644
end

cookbook_file "/etc/elasticsearch/userdict_ja.txt" do
    mode 00644
end

bash "update_es_yml" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  cat /etc/elasticsearch/elasticsearch.yml | grep -v cluster.name | grep -v node.name | grep -v index.number_of_shards | grep -v index.number_of_replicas | grep -v http.jsonp.enable > /tmp/elasticsearch.yml.tmp
  echo "cluster.name: elasticsearch-codelibs" >> /tmp/elasticsearch.yml.tmp
  echo "node.name: \"ES Node 1\"" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_shards: 1" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_replicas: 0" >> /tmp/elasticsearch.yml.tmp
  echo "http.jsonp.enable: true" >> /tmp/elasticsearch.yml.tmp
  mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
  sed -e "s/es.logger.level: INFO/es.logger.level: DEBUG/" /etc/elasticsearch/logging.yml > /tmp/logging.yml.tmp
  mv -f /tmp/logging.yml.tmp /etc/elasticsearch/logging.yml
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

