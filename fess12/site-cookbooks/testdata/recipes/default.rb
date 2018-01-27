package "git" do
    action :install
end

git "/opt/fess-testdata" do
  repository "https://github.com/codelibs/fess-testdata.git"
  revision "master"
  action :sync
end

directory "/opt/fess-data/csv" do
  action :create
  recursive true
end

cookbook_file "/opt/fess-data/csv/test.csv" do
    mode 00644
end

