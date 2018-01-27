case node['platform']
when "ubuntu", "debian"
  # TODO
when "centos", "redhat"
  yum_package 'java-1.8.0-openjdk' do
    action :install
  end
end

