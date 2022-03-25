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

For a Slurm client:
```
include ::profile_slurm::client
```

For a Slurm scheduler:
```
include ::profile_slurm::scheduler
```

For a Slurm monitor node (Include this on the node the hosts the slurmdb):
```
include ::profile_slurm::monitor
```


## Usage

You will want to set these hiera variables for Slurm clients:
```
profile_slurm::client::firewall::sources:
  - "192.168.0.0/24"  # Allow access to slurmd from 192.168.0.0/24 net
```


You will want to set these hiera variables for scheduler nodes:
```
profile_slurm::scheduler::firewall::sources:
  - "192.168.0.0/24"  # Allow access to slurmdbd and slurmctld from 192.168.0.0/24 net
```

You will want to set these hiera variables for a node running the telegraf monitoring:
```
profile_slurm::telegraf::telegraf::slurm_job_table: ""
profile_slurm::telegraf::telegraf::slurm_password: "%{lookup('slurm::slurmdbd_storage_pass')}"  # This is a VAULT lookup, use the keyname you have chosen for storing the slurmdb user account password
```


## Dependencies

n/a

## Reference

See: [REFERENCE.md](REFERENCE.md)


