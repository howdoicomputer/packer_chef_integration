default['packer_chef_integration'].tap do |pci|
  pci['chef_server_url']        = nil
  pci['validation_client_name'] = nil
  pci['ssl_verify']             = false
  pci['packer_staging_dir']     = '/tmp/packer-chef-client'
end
