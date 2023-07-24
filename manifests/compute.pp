# @summary Setup slurm config for slurm compute node
#
# @example
#   include profile_slurm::compute
class profile_slurm::compute {
  include profile_slurm::compute::storage
  include profile_slurm::crons
  include profile_slurm::files
}
