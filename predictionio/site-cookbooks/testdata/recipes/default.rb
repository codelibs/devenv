package "git" do
    action :install
end

package "python3-pip" do
    action :install
end

git "/opt/predictionio" do
  repository "https://github.com/jpioug/incubator-predictionio.git"
  action :sync
end

