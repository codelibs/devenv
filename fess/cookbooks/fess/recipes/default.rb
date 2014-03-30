#version = '9.2.0-SNAPSHOT'
version = '9.1.0-1'
db_name = 'h2'
#db_name = 'mysql'
filename = "fess-server-#{db_name}-#{version}.noarch.rpm"
remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"
mysql_config = "/root/fess_mysql_config"

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

bash "mysql_config" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  echo "FESS_PASSWORD=fessdb" > #{mysql_config}
  echo "ROBOT_PASSWORD=robotdb" >> #{mysql_config}
  echo "MYSQL_PASSWORD=mysqldb" >> #{mysql_config}
  bash /opt/fess/extension/mysql/install.sh #{mysql_config}
  EOH
  only_if { db_name == 'mysql' && ! ::File.exists?(mysql_config) }
end

