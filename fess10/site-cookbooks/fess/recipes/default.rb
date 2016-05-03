version = '10.0.4-SNAPSHOT'

service "fess" do
    supports :status => true, :restart => true, :reload => true
end

case node['platform']
when "ubuntu", "debian"
  filename = "fess.deb"
  # remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

  # remote_file "/tmp/#{filename}" do
  #     source "#{remote_uri}"
  #     mode 00644
  # end

  cookbook_file "/tmp/#{filename}" do
    source "fess.deb"
  end

  package "fess" do
      action :install
      source "/tmp/#{filename}"
      options "--force-depends"
      provider Chef::Provider::Package::Dpkg
      notifies :restart, resources(:service => "fess")
      notifies :enable, resources(:service => "fess")
  end
when "centos", "redhat"
  filename = "fess-#{version}.rpm"
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
      notifies :restart, resources(:service => "fess")
      notifies :enable, resources(:service => "fess")
  end
end

bash "copy_plugins" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  cp -r /usr/share/fess/es/plugins/* /usr/share/elasticsearch/plugins/
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

