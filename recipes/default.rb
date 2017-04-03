#
# Cookbook:: packer_chef_integration
# Recipe:: default
#
# Copyright:: 2017, The Authors
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

template '/etc/systemd/system/start-chef.service' do
  source 'start-chef.service.erb'
end

template '/usr/local/bin/start-chef.sh' do
  source 'start-chef.sh.erb'

  mode 0744
end

template '/etc/chef/client.rb' do
  variables(
    chef_server_url:        node['packer_chef_integration']['chef_server_url'],
    validation_client_name: node['packer_chef_integration']['validation_client_name'],
    ssl_verify:             node['packer_chef_integration']['ssl_verify']
  )

  source 'client.rb.erb'
  mode   0644
end

bash 'enable service' do
  code <<-EOH
  systemctl daemon-reload
  systemctl enable start-chef.service
  EOH
end

file '/etc/chef/validation.pem' do
  owner   'root'
  group   'root'
  mode    0755
  content ::File.open("#{node['packer_chef_integration']['packer_staging_dir']}/validation.pem").read
  action  :create
end

ruby_block 'write runlist' do
  block do
    require 'json'

    first_boot = JSON.parse(
      File.read "#{node['packer_chef_integration']['packer_staging_dir']}/first-boot.json"
    )

    first_boot['run_list'].delete_if { |a| a.to_s.match('packer_chef_integration') }

    File.write('/etc/chef/first-boot.json', JSON.generate(first_boot))
  end
end
