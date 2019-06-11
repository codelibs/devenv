#version = '12.0.3-SNAPSHOT'
#version = '12.1.2-SNAPSHOT'
#version = '12.2.0-SNAPSHOT'
#version = '12.4.4-SNAPSHOT'
#version = '12.5.2-SNAPSHOT'
version = '12.6.2-SNAPSHOT'
es_version = '6.7.2'

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

service "fess" do
    supports :status => true, :restart => true, :reload => true
end

case node['platform']
when "ubuntu", "debian"
  filename = "fess-#{version}.deb"
  remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"
  #remote_uri = "https://github.com/codelibs/fess/releases/download/fess-#{version}/#{filename}"

  remote_file "/tmp/#{filename}" do
   source "#{remote_uri}"
   mode 00644
  end

  package "fess" do
   action :install
   source "/tmp/#{filename}"
   options "--force-depends"
   provider Chef::Provider::Package::Dpkg
   notifies :enable, resources(:service => "fess")
  end

  apt_update 'update'
when "centos", "redhat"
  filename = "fess-#{version}.rpm"
  remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"
  #remote_uri = "https://github.com/codelibs/fess/releases/download/fess-#{version}/#{filename}"

  remote_file "/tmp/#{filename}" do
   source "#{remote_uri}"
   mode 00644
  end

  package "fess" do
   action :install
   source "/tmp/#{filename}"
   options "--nodeps"
   provider Chef::Provider::Package::Rpm
   notifies :enable, resources(:service => "fess")
  end

  package "ImageMagick" do
   action :install
  end

  package "unoconv" do
   action :install
  end
end

package "ant" do
    action :install
end

bash "install_plugins" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  rm -rf /usr/share/elasticsearch/plugins
  mkdir /usr/share/elasticsearch/plugins
  ant -f /usr/share/fess/bin/plugin.xml -Dtarget.dir=/tmp -Dplugins.dir=/usr/share/elasticsearch/plugins -Delasticsearch.version=#{es_version} install.plugins

  EOH
  notifies :restart, resources(:service => "elasticsearch")
  notifies :restart, resources(:service => "fess")
end

