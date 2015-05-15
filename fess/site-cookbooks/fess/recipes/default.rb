version = '9.4.0-SNAPSHOT'
#version = '9.3.3-1'
#db_name = 'h2'
db_name = 'mysql'
os_name = 'el6'
#os_name = 'el7'
filename = "fess-server-#{db_name}-#{version}.#{os_name}.noarch.rpm"
remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"
mysql_config = "/root/fess_mysql_config"

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

