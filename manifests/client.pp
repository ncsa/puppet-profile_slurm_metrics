# @summary Setup slurm config for slurm client
#
# @example
#   include profile_slurm::client
class profile_slurm::client {
  include profile_slurm::client::firewall
  include profile_slurm::crons
  include profile_slurm::files
}
