version = '10.0.0-SNAPSHOT'
filename = "fess-#{version}.rpm"
remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

service "fess" do
    supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{filename}" do
    source "#{remote_uri}"
    mode 00644
end

package "fess" do
    action :install
    source "/tmp/#{filename}"
    options "--nodeps"
    provider Chef::Provider::Package::Rpm
    notifies :restart, resources(:service => "fess")
    notifies :enable, resources(:service => "fess")
end

bash "copy_plugins" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  cp -r /usr/share/fess/es/plugins/* /usr/share/elasticsearch/plugins/
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

