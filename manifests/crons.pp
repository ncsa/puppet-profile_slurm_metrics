# @summary Manage Ad-hoc crons and related scripts.
#
# Manage Ad-hoc crons and related scripts.
#
# @param crons
#   Cron resources.
#
# @example
#   include profile_slurm::crons
class profile_slurm::crons (
  Hash $crons,
) {
  $cron_defaults = {
    ensure => present,
    user   => 'root',
  }
  ensure_resources('cron', $crons, $cron_defaults )
}
