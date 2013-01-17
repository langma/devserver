#
# Cookbook Name:: kafka2
# Description:: Apache Kafka install and config
# Recipe:: default

# == Recipes
include_recipe "java"
include_recipe "runit"

user = node[:kafka][:user]
group = node[:kafka][:group]

if node[:kafka][:broker_id].nil? || node[:kafka][:broker_id].empty?
    node[:kafka][:broker_id] = node[:ipaddress].gsub(".","")
end

if node[:kafka][:broker_host_name].nil? || node[:kafka][:broker_host_name].empty?
    node[:kafka][:broker_host_name] = node[:fqdn]
end

log "Broker id: #{node[:kafka][:broker_id]}"
log "Broker name: #{node[:kafka][:broker_host_name]}"

# == Users

# setup kafka group
group group do
end

# setup kafka user
user user do
  comment "Kafka user"
  gid "kafka"
  home "#{node[:kafka][:install_dir]}"
  shell "/bin/noshell"
  supports :manage_home => false
end

log "Install dir: #{node[:kafka][:install_dir]}"
directory node[:kafka][:install_dir] do
  owner user
  group group
  mode 00755
  recursive true
  action :create
end

package = "#{Chef::Config[:file_cache_path]}/#{node[:kafka][:tarball]}"
log "Package: #{package}"

remote_file package do
  source "#{node[:kafka][:download_url]}/#{node[:kafka][:tarball]}"
  mode 00644
  action :create_if_missing
  # checksum node[:kafka][:checksum]
end

service_dir = "#{node[:kafka][:install_dir]}/kafka-#{node[:kafka][:version]}"

execute "untar and rename kafka source" do
  user  user
  group group
  cwd "#{node[:kafka][:install_dir]}"
  command "rm -rf kafka-#{node[:kafka][:version]}-src && tar zxvf #{package} && mv kafka-#{node[:kafka][:version]}-src kafka-#{node[:kafka][:version]}"
  action :run
  creates service_dir
end

bash "sbt update" do
  user  user
  group group
  cwd service_dir
  code <<-EOH
export PATH=$PATH:/usr/lib/jvm/default-java/bin/
/bin/bash sbt update
EOH
  creates "#{service_dir}/lib_managed"
end

bash "sbt package" do
  user  user
  group group
  cwd service_dir
  code <<-EOH
export PATH=$PATH:/usr/lib/jvm/default-java/bin/
/bin/bash sbt package
EOH
  creates "#{service_dir}/perf/target"
end

# fix host name
ruby_block "fix hostname" do
	block do
		ipaddress = node[:network][:interfaces][:eth1][:addresses].select { |address, data| data[:family] == "inet" }[0][0]
		file = Chef::Util::FileEdit.new("#{service_dir}/config/server.properties")
  		file.search_file_replace("#hostname=", "hostname=#{ipaddress}")
      file.search_file_replace("zk.connect=localhost:2181", "zk.connect=#{ipaddress}:2181")
  		file.write_file
  	end
end

# create the runit service
runit_service "zookeeper" do
  options({
    :log_dir => node[:kafka][:log_dir],
    :install_dir => service_dir,
    #:java_home => node['java']['java_home'],
    :user => user
  })
end

# create the runit service
runit_service "kafka" do
  options({
    :log_dir => node[:kafka][:log_dir],
    :install_dir => service_dir,
    #:java_home => node['java']['java_home'],
    :user => user
  })
end
