version = '9.0.0-SNAPSHOT'
db = 'h2'
filename = "fess-server-#{db}-#{version}.noarch.rpm"
remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

remote_file "/tmp/#{filename}" do
    source "#{remote_uri}"
    mode 00644
end

package "fess" do
    action :install
    source "/tmp/#{filename}"
    options "--nodeps"
    provider Chef::Provider::Package::Rpm
end

service "fess" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end
