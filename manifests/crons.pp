# @summary Manage Ad-hoc crons and related scripts.
#
# Manage Ad-hoc crons and related scripts.
#
# @param crons
#   Cron resources.
#
# @param files
#   File resources.
#
# @example
#   include profile_slurm::crons
class profile_slurm::crons (
  Hash $crons,
  Hash $files,
) {
  $file_defaults = {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  ensure_resources('file', $files, $file_defaults )

  $cron_defaults = {
    ensure => present,
    user   => 'root',
  }
  ensure_resources('cron', $crons, $cron_defaults )
}
