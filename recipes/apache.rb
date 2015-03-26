#
# Cookbook Name:: pgd
# Recipe:: apache
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
include_recipe 'apache2::default'
include_recipe 'apache2::mod_wsgi'

python_version = node['languages']['python']['version']
version = python_version.split('.')
version = version[0] + '.' + version[1]
python_version = "python#{version}"

python_path = ::File.join(node['pgd']['virtualenv_path'], 'lib',
                          python_version, 'site-packages')
wsgi_path = ::File.join(node['pgd']['pgd_path'], 'wsgi.py')

web_app node['pgd']['application_name'] do
  template 'pgd_apache_vhost.conf.erb'
  server_name node['hostname']
  server_aliases node['pgd']['apache']['server_aliases']
  cookbook 'pgd_cookbook'
  server_name node['pgd']['apache']['server_name']
  app node['pgd']
  processes node['pgd']['apache']['processes']
  threads node['pgd']['apache']['threads']
  wsgi_process_group 'pgd'
  wsgi_path wsgi_path
  python_path python_path
end
