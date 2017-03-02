spark_file = "spark-1.6.3-bin-hadoop2.6.tgz"
spark_url = "http://d3kbcqa49mib13.cloudfront.net/#{spark_file}"

remote_file "/tmp/#{spark_file}" do
 source "#{spark_url}"
 mode 00644
end

bash "install_spark" do
  user "root"
  cwd "/opt"
  code <<-EOH
  tar zxvf /tmp/#{spark_file}
  ln -s spark-* spark
  EOH
end
