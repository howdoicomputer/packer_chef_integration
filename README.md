# packer_chef_integration

PCI is a very, very simple cookbook that is meant to be included in a Packer chef-client provisioner's run list. It is meant to be ran while Packer is building an EBS backed AMI - it will copy the used validation key into /etc/chef, setup Chef to be ran at boot, and then remove itself from the node's run list. The init script that converges chef-client when the node comes up removes the validation key. However, the validation key is baked into the image so, uh, there is that.

Example:

```
{
  "type": "chef-client",
  "server_url": "https://chef.foobar.com/organizations/foobar",
  "run_list": [
    "recipe[my_application::default]",
    "recipe[chef-client]",
    "recipe[packer_chef_integration]"
  ],
  "validation_key_path": "/home/howdoicomputer/.chef/chef12",
  "validation_client_name": "howdoicomputer",
  "ssl_verify_mode": "verify_none"
}
```
