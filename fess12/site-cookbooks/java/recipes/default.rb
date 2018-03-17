jdk_version = "8"

case node['platform']
when "ubuntu", "debian"
  case jdk_version
  when "8"
    apt_package 'openjdk-8-jdk' do
      action :install
    end
  when "9"
    apt_package 'openjdk-9-jdk' do
      action :install
      options '-o Dpkg::Options::="--force-overwrite"'
    end
    bash 'use_java9' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      update-alternatives --set java /usr/lib/jvm/java-9-openjdk-amd64/bin/java
      EOH
    end
  end
when "centos", "redhat"
  case jdk_version
  when "8"
    yum_package 'java-1.8.0-openjdk' do
      action :install
    end
  when "9"
    remote_file "/etc/yum.repos.d/openjdk9.repo" do
     source "https://copr.fedorainfracloud.org/coprs/omajid/openjdk9/repo/epel-7/omajid-openjdk9-epel-7.repo"
     mode 00644
    end
    yum_package 'java-9-openjdk' do
      action :install
    end
    bash 'use_java9' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      alternatives --set java `ls /usr/lib/jvm/java-9-openjdk-9.0.0.*/bin/java`
      EOH
    end
  end
end

