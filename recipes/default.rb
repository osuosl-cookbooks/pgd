#
# Cookbook Name:: pgd
# Recipe:: default
#
# Copyright 2015, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'pgd_cookbook::check-attributes'
include_recipe 'pgd_cookbook::_centos'
include_recipe 'yum-osuosl'
include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'python'
include_recipe 'mysql::client'
include_recipe 'mysql::server'
include_recipe 'pgd_cookbook::apache'
include_recipe 'yum-ius'

secrets = Chef::EncryptedDataBagItem.load('pgd', 'pgd_secrets')

python_virtualenv node['pgd']['virtualenv_path'] do
  interpreter 'python2.7'
  owner node['pgd']['user']
  group node['pgd']['group']
  action :create
end

# cairocffi dependency
package 'libffi-devel'
# custom dssp package for pgd
package 'osuosl-dssp' do
  options '--nogpgcheck'
  action :install
end

directory node['pgd']['pgd_path'] do
  owner node['pgd']['user']
  group node['pgd']['group']
  mode '0755'
  action :create
end

git node['pgd']['pgd_path'] do
  repository node['pgd']['git']['repository']
  revision node['pgd']['git']['revision']
  user node['pgd']['user']
  group node['pgd']['group']
end

python_pip "#{node['pgd']['pgd_path']}/requirements.txt" do
  options '-r'
  virtualenv node['pgd']['virtualenv_path']
  action :install
end

#::File.join(node['ganeti_webmgr']['config_dir'], 'config.yml')
config_file = "#{node['pgd']['pgd_path']}/settings.py"

template config_file do
  source 'django_settings.py.erb'
  owner node['pgd']['user']
  group node['pgd']['group']
  mode '0644'
  variables(
    app: node['pgd'],
    secrets: secrets
           )
end

include_recipe 'pgd_cookbook::database'
