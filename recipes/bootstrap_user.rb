#
# Cookbook Name:: pgd
# Recipe:: bootstrap_user
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
venv = node['pgd']['virtualenv_path']
venv_bin = ::File.join(venv, 'bin')
python = ::File.join(venv_bin, 'python')
# django_admin = ::File.join(venv_bin, 'django-admin.py')
manage = ::File.join(node['pgd']['pgd_path'], 'manage.py')

env = {
  'PGD_CONFIG_DIR' => node['pgd']['virtualenv_path'].to_s,
  'DJANGO_SETTINGS_MODULE' => 'settings'
}

# Use the attributes to bootstrap users if set, otherwise use databag users
username = node['pgd']['username']
email = node['pgd']['email']
password = node['pgd']['password']

log 'Creating django superuser #{username}'

execute 'create_superuser' do
  ignore_failure true
  command <<-EOS
  #{python} #{manage} createsuperuser --noinput --username=#{username}\
    --email=#{email}
  #{python} -c \"from django.contrib.auth.models import User;\
    u=User.objects.get(username='#{username}');\
    u.set_password('#{password}');\
    u.save();\"
  EOS
  user node['pgd']['user']
  group node['pgd']['group']
  environment env
  cwd node['pgd']['pgd_path']
end
