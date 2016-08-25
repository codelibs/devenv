version = '10.2.0-SNAPSHOT'

service "fess" do
    supports :status => true, :restart => true, :reload => true
end

case node['platform']
when "ubuntu", "debian"
  filename = "fess-#{version}.deb"
  remote_uri = "http://fess.codelibs.org/snapshot/#{filename}"

  remote_file "/tmp/#{filename}" do
   source "#{remote_uri}"
   mode 00644
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

