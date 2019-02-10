#es_version = "6.1.3"
#es_version = "6.2.2"
#es_version = "6.5.4"
es_version = "6.6.0"
es_cluster_name = "elasticsearch"

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

bash 'copy_es_yml' do
  user "root"
  cwd "/etc/elasticsearch"
  code <<-EOH
    cp /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml.orig
  EOH
  not_if { ::File.exist?("/etc/elasticsearch/elasticsearch.yml.orig") }
end

bash "update_es_yml" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  cat /etc/elasticsearch/elasticsearch.yml.orig > /etc/elasticsearch/elasticsearch.yml
  echo "cluster.name: #{es_cluster_name}" >> /etc/elasticsearch/elasticsearch.yml
  echo "node.name: \"ES Node 1\"" >> /etc/elasticsearch/elasticsearch.yml
  echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
  echo 'http.cors.allow-origin: "*"' >> /etc/elasticsearch/elasticsearch.yml
  echo 'network.host: "0"' >> /etc/elasticsearch/elasticsearch.yml
  echo "configsync.config_path: /var/lib/elasticsearch/config" >> /etc/elasticsearch/elasticsearch.yml
  EOH
end

