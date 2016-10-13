rpm_version = '4.5'
rpm_file = "gitbucket-#{rpm_version}-1.noarch.rpm"
rpm_uri = "http://maven.codelibs.org/archive/gitbucket/#{rpm_version}/#{rpm_file}"
plugin_version = '1.0.0-SNAPSHOT'
plugin_file = "gitbucket-fess-plugin_2.11-#{plugin_version}.jar"
plugin_uri = "https://oss.sonatype.org/content/repositories/snapshots/org/codelibs/gitbucket/gitbucket-fess-plugin_2.11/#{plugin_version}/#{plugin_file}"

service "gitbucket" do
  supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{rpm_file}" do
  source "#{rpm_uri}"
  mode 00644
end

package "gitbucket" do
  action :install
  source "/tmp/#{rpm_file}"
  options "--nodeps"
  provider Chef::Provider::Package::Rpm
  notifies :enable, resources(:service => "gitbucket")
end

directory "/var/lib/gitbucket/plugins" do
  action :create
  owner "gitbucket"
  group "gitbucket"
end

remote_file "/var/lib/gitbucket/plugins/#{plugin_file}" do
  source "#{plugin_uri}"
  mode 00644
  owner "gitbucket"
  group "gitbucket"
  notifies :restart, resources(:service => "gitbucket")
end

