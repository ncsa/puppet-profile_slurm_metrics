# profile_slurm

![pdk-validate](https://github.com/ncsa/puppet-profile_slurm/workflows/pdk-validate/badge.svg)
![yamllint](https://github.com/ncsa/puppet-profile_slurm/workflows/yamllint/badge.svg)

NCSA Customizations for Slurm

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Dependencies](#dependencies)
1. [Reference](#reference)


## Description

This is a module to add NCSA customizations to a Slurm client/scheduler/monitor node. It does not do the initial install/config of Slurm, that is handled by other modules (see [treydock/slurm](https://forge.puppet.com/modules/treydock/slurm) and [treydock/slurm_providers](https://forge.puppet.com/modules/treydock/slurm_providers) )

Currently this module:
- Adds more fine grained controls for firewalls, so will want to set `slurm::manage_firewall: false` from treydock/slurm to `false`
- Allows telegraf scripts to be deployed which collect Slurm metrics.


## Setup

For a Slurm submit node (generally cluster login nodes):
```ruby
include ::profile_slurm::client
```

For a Slurm compute node:
```ruby
include ::profile_slurm::client
include ::profile_slurm::compute
```

For a Slurm scheduler:
```ruby
include ::profile_slurm::scheduler
```

For a Slurm monitor node (Include this on the node that runs `slurmdbd`):
```ruby
include ::profile_slurm::monitor
```

For a node with slurmrestd:
```ruby
include ::profile_slurm::slurmrestd
```
NOTE: This has NOT been tested on a standalone node, only on a scheduler.
NOTE: Having slurmrestd to listen on the internet is not a great idea, and it's very bad if there is no web proxy in front of it for additional security. Configuration of such a proxy is not covered by this profile.


## Usage

You will want to set these hiera variables for Slurm submit nodes (generally cluster login nodes):
```yaml
profile_slurm::client::firewall::sources:
  - "192.168.0.0/24"  # Allow access to slurmd from 192.168.0.0/24 net
```

You will generally want to manage the firewall as well as dependencies on local storage for Slurm compute nodes:
```yaml
profile_slurm::client::firewall::sources:
  - "192.168.0.0/24"  # Allow access to slurmd from 192.168.0.0/24 net
profile_slurm::compute::dependencies:
  - "Gpfs::Bindmount['/scratch']"
...
  - "Gpfs::Nativemount['cluster']"
  - "Lvm::Logical_volume[local]"
  - "Profile_lustre::Nativemount_resource['/projects']"
...
profile_slurm::compute::storage::tmpfs_dir: "/local/slurmjobs"
profile_slurm::compute::storage::tmpfs_dir_refreshed_by: "Lvm::Logical_volume[local]"
```

You will want to set these hiera variables for scheduler nodes:
```yaml
profile_slurm::scheduler::firewall::sources:
  - "192.168.0.0/24"  # Allow access to slurmdbd and slurmctld from 192.168.0.0/24 net
# and generally specify dependencies on local storage:
profile_slurm::scheduler::dependencies:
  - "Mount['/slurm']"
  - "Mount['/var/log/slurm']"
  - "Mount['/var/spool/slurmctld.state']"
# lower this timeout from default of 60 sec; this prevents Puppet runs from
# taking an excessive amount of time if the id_check fails (in which case
# slurmctld will fail to start but Puppet will try to contact slurmctld
# until this timeout is reached, prior to running 'scontrol reconfig')
slurm::slurmctld_conn_validator_timeout: 20
```

To set up slurmrestd on a scheduler, configure these Hiera variables:
```yaml
# common.yaml:
## make slurmrestd dependent on slurmctld
profile_slurm::slurmrestd::dependencies:
  - "Service['slurmctld']"
## open up the firewall, if needed
profile_slurm::slurmrestd::firewall_sources:
  - "A.B.C.D/XX"  # cluster network
slurm::auth_alt_types:
  - auth/jwt
## optional, but suggested to explicitly set this
slurm::slurmrestd_disable_token_creation: false

# role/slurm_scheduler.yaml:
slurm::slurmrestd: true

# <encrypted and stored in eyaml>:
slurm::jwt_key_content: ...

# node/<scheduler_hostname>.yaml:
## suggested to restrict slurmrestd to the cluster network
slurm::slurmrestd_listen_address: 172.31.2.8
```

To install arbitrary files and symlinks, set this Hiera variable:
```yaml
profile_slurm::files::files:
  ...
```

### Telegraf Monitoring

You will want to set these hiera variables for a node running the telegraf monitoring:
```yaml
profile_slurm::telegraf::telegraf::slurm_job_table: ""
```

If using MySQL ***with*** socket authentication, you'll also need to set the following because the `telegraf` user cannot use socket auth to connect as another user:
```yaml
profile_slurm::telegraf::slurm_username: "telegraf"
```

If using MySQL ***without*** socket authentication, you'll also need to set the following to lookup the password:
```yaml
profile_slurm::telegraf::telegraf::slurm_password: "%{lookup('slurm::slurmdbd_storage_pass')}"  # This is a VAULT lookup, use the keyname you have chosen for storing the slurmdb user account password
```


## Dependencies

n/a


## Reference

See: [REFERENCE.md](REFERENCE.md)

