version = '4.0.0_M1'
filename = "opendj-#{version}-1.noarch.rpm"
remote_uri = "https://maven.codelibs.org/archive/opendj/#{version}/#{filename}"
setup_done_file = "/opt/setup/.opendj_done"

package "openldap-clients" do
    action :install
end

directory "/opt/setup" do
  action :create
  recursive true
end

cookbook_file "/opt/setup/setup-opendj.sh" do
    mode 00755
end

cookbook_file "/opt/setup/create-group.ldif" do
    mode 00644
end

cookbook_file "/opt/setup/create-role.ldif" do
    mode 00644
end

cookbook_file "/opt/setup/user-data.ldif" do
    mode 00644
end

service "opendj" do
    supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{filename}" do
  source "#{remote_uri}"
  mode 00644
end

package "opendj" do
 action :install
 source "/tmp/#{filename}"
 options "--nodeps"
 provider Chef::Provider::Package::Rpm
 notifies :restart, resources(:service => "opendj")
 notifies :enable, resources(:service => "opendj")
end

bash 'setup_opendj' do
  code <<-EOH
    /bin/bash -x /opt/setup/setup-opendj.sh
    touch #{setup_done_file}
    EOH
  not_if { ::File.exists?(setup_done_file) }
end


