# @summary Verify that identity services (e.g., sssd) are working.
# The primary use case is to ensure that sssd is configured
# and running prior to starting slurmctld so we do not lose
# reservations or prevent users from submitting jobs (both of
# which require resolution of users and groups/membership).
#
# Verify that identity services (e.g., sssd) are working.
#
# @param group
#   Group to check for in order to verify that identity services
#   are working.
#
# @example
#   include profile_slurm::id_check
class profile_slurm::id_check (
  String $group
) {
  # If the receipt_file doesn't exist, run the slurm_id_check,
  # and if that succeeds, write the receipt_file.
  $receipt_file = '/etc/slurm/id_check_success'
  exec { 'slurm_id_check':
    command => "getent group ${group} && touch ${receipt_file}",
    onlyif  => "test ! -f ${receipt_file}",
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
}
