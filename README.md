# packer_chef_integration

PCI is a very, very simple cookbook that is meant to be included in a Packer chef-client provisioner's run list. It is meant to be ran while Packer is building an EBS backed AMI - it will copy the used validation key into /etc/chef, setup Chef to be ran at boot, and then remove itself from the node's run list. The init script that converges chef-client when the node comes up removes the validation key. However, the validation key is baked into the image so, uh, there is that.

If you mean to keep the validation key secret from anybody who has access to the generated image then you'll have to wrap this cookbook aaaaand then remove the resource that copies the key. This means that you'll have to be responsible for another method of key distribution. Like Vault, maybe!

Note: this was written for Ubuntu 16.04 but any distribution that uses SystemD will work just fine... probably.

**Example:**

```
"provisioners": [
  {
    "type": "chef-client",
    "server_url": "https://chef.foobar.com/organizations/foobar",
    "run_list": [
      "recipe[my_service]",
      "recipe[chef-client]",
      "recipe[packer_chef_integration]"
    ],
    "json": {
      "packer_chef_integration": {
        "chef_server_url": "https://foobar.thislife.com/organizations/foobar",
        "validation_client_name": "howdoicomputer"
      }
    },
    "validation_key_path": "/home/howdoicomputer/.chef/validation.pem",
    "validation_client_name": "howdoicomputer",
    "ssl_verify_mode": "verify_none"
  }
]
```

Here is, like, the attributes needed:

```
default['packer_chef_integration'].tap do |pci|
  pci['chef_server_url']        = nil
  pci['validation_client_name'] = nil
  pci['ssl_verify']             = false
  pci['packer_staging_dir']     = '/tmp/packer-chef-client'
end
```

---
Made with :heart:
