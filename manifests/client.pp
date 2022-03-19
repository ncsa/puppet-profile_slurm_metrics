# @summary Setup slurm config for slurm client
#
# @example
#   include profile_slurm::client
class profile_slurm::client {

  include profile_slurm::client::firewall

}
