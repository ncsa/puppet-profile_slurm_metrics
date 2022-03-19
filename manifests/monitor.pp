# @summary Sets up monitoring and collecting of slurm scheduler stats
#
# @example
#   include profile_slurm::monitor
class profile_slurm::monitor {

  include profile_slurm::telegraf::slurm_detail_stats
  include profile_slurm::telegraf::slurm_job_efficiency
  include profile_slurm::telegraf::slurm_stats
  include profile_slurm::telegraf::telegraf

}
