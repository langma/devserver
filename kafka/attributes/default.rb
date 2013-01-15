#
# Cookbook Name:: kafka
# Attributes:: default

# Install
default[:kafka][:user] = "kafka"
default[:kafka][:group] = "kafka"

default[:kafka][:version] = "0.7.2-incubating"
default[:kafka][:tarball] = "kafka-#{default[:kafka][:version]}-src.tgz"
default[:kafka][:download_url] = "http://www.nic.funet.fi/pub/mirrors/apache.org/incubator/kafka/kafka-#{default[:kafka][:version]}"

default[:kafka][:install_dir] = "/usr/local/kafka"
default[:kafka][:log_dir] = "/usr/local/kafka/logs"