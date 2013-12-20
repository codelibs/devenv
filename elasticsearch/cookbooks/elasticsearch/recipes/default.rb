filename = "elasticsearch-0.90.8.noarch.rpm"
remote_uri = "https://download.elasticsearch.org/elasticsearch/elasticsearch/#{filename}"

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

service "elasticsearch" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end
