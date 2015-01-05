#
# Cookbook Name:: pgd_cookbook
# Recipe:: default
#
# Copyright 2014, OSU Open Source Lab 
#
# All rights reserved - Do Not Redistribute
#

include_recipe "pgd_cookbook::_centos" 
include_recipe "pgd_cookbook::check-attributes"
include_recipe "build-essential"
include_recipe "git"
include_recipe "python"
include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "pgd_cookbook::apache"
include_recipe "yum-ius"

service 'apache2' do
  action [ :enable, :start ]
end

python_virtualenv node['pgd']['virtualenv_path'] do
  interpreter "python2.7"
  owner node['pgd']['user']
  group node['pgd']['group']
  action :create
end

# cairocffi dependency
package "libffi-devel"

git node['pgd']['pgd_path'] do
  repository node['pgd']['git']['repository']
  revision node['pgd']['git']['revision']
  user node['pgd']['user']
  group node['pgd']['group']
end

python_pip "#{node['pgd']['pgd_path']}/requirements.txt" do
  options "-r"
  virtualenv node['pgd']['virtualenv_path']
  action :install
end

config_file = "#{node['pgd']['pgd_path']}/pgd/settings.py" #::File.join(node['ganeti_webmgr']['config_dir'], 'config.yml')
template config_file do
  source "django_settings.py.erb"
  owner node['pgd']['user']
  group node['pgd']['group']
  mode "0644"
  variables({
  	:app => node['pgd'],
    :secrets => secrets
  })
end

include_recipe "pgd_cookbook::database"
