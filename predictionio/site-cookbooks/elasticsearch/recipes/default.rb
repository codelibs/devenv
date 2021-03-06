es_version = "5.2.2"

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

case node['platform']
when "ubuntu", "debian"
  filename = "elasticsearch-#{es_version}.deb"
  remote_uri = "https://artifacts.elastic.co/downloads/elasticsearch/#{filename}"

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
  remote_uri = "https://artifacts.elastic.co/downloads/elasticsearch/#{filename}"

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
  echo "http.cors.enabled: true" >> /tmp/elasticsearch.yml.tmp
  echo 'http.cors.allow-origin: "*"' >> /tmp/elasticsearch.yml.tmp
  echo 'network.host: "0"' >> /tmp/elasticsearch.yml.tmp
  mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end
