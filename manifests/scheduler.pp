# @summary Sets up configs for scheduler node
#
#
# @example
#   include profile_slurm::scheduler
class profile_slurm::scheduler {
  include profile_slurm::crons
  include profile_slurm::files
  include profile_slurm::scheduler::firewall
  include profile_slurm::scheduler::storage
}
