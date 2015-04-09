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

python_webapp 'pgd_core' do
  create_user true
  owner node['pgd']['user']
  group node['pgd']['group']

  repository node['pgd']['repository']
  revision node['pgd']['revision']

  path node['pgd']['pgd_path']
  virtualenv_path node['pgd']['virtualenv_path']
  requirements_file "#{ node['pgd']['pgd_path'] }/requirements.txt"

  config_template 'django_settings.py.erb'
  config_destination "#{ node['pgd']['pgd_path'] }/settings.py"
  config_vars(
    app: node['pgd'],
    secrets: secrets
             )
  interpreter 'python2.7'
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

include_recipe 'pgd_cookbook::database'
