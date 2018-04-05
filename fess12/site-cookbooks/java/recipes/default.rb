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
    bash 'use_java9' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      curl -o openjdk-9.tar.gz https://download.java.net/java/GA/jdk9/9.0.4/binaries/openjdk-9.0.4_linux-x64_bin.tar.gz
      tar xzvf openjdk-9.tar.gz
      mkdir -p /usr/lib/jvm
      mv jdk-9.0.4 /usr/lib/jvm
      alternatives --install /usr/bin/java java `ls /usr/lib/jvm/jdk-9*/bin/java` 1
      alternatives --set java `ls /usr/lib/jvm/jdk-9*/bin/java`
      EOH
    end
  end
end

