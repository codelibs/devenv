jdk_version = "11"

case node['platform']
when "ubuntu", "debian"
  case jdk_version
  when "8"
    apt_package 'openjdk-8-jdk' do
      action :install
    end
  when "11"
    apt_package 'openjdk-11-jdk' do
      action :install
      options '-o Dpkg::Options::="--force-overwrite"'
    end
    bash 'use_java11' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
      EOH
    end
  end
when "centos", "redhat"
  case jdk_version
  when "8"
    yum_package 'java-1.8.0-openjdk' do
      action :install
    end
  when "11"
    bash 'use_java11' do
      user 'root'
      cwd '/tmp'
      code <<-EOH
      curl -L -o openjdk-11.tar.gz "https://api.adoptopenjdk.net/v2/binary/releases/openjdk11?openjdk_impl=hotspot&os=linux&arch=x64&release=latest&type=jdk"
      tar xzvf openjdk-11.tar.gz
      mkdir -p /usr/lib/jvm
      mv jdk-11* /usr/lib/jvm
      alternatives --install /usr/bin/java java `ls /usr/lib/jvm/jdk-11*/bin/java` 1
      alternatives --set java `ls /usr/lib/jvm/jdk-11*/bin/java`
      EOH
    end
  end
end

