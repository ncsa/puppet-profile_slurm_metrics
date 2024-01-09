# @summary Sets up configs for scheduler node
#
# @param dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up Slurm on a scheduler. Should be in the form that would
#   be specified as a requirement ("before") various Slurm scheduler
#   resources, e.g.:
#     "Mount['/slurm']"
#     "Mount['/var/log/slurm']"
#     "Mount['/var/spool/slurmctld.state']"
#   If the node also runs the Slurm accounting DB, e.g., using MySQL/MariaDB,
#   you will generally want to include that service to ensure it is running
#   prior to slurmdbd starting.
#     "Service[mysqld]"
#
# @param configure_after_dependencies
#   Optionally list resources (e.g., services) that require any of the
#   items from the $dependencies parameter in order to function.
#
# @param slurmctld_id_check_dropin_content
#   Content for a systemd dropin file that ensures the service
#   will only start up if the receipt file from
#   profile_slurm::id_check exists.
#
# @example
#   include profile_slurm::scheduler
class profile_slurm::scheduler (

  Array[String]  $dependencies,
  Array[String]  $configure_after_dependencies,
  String         $slurmctld_id_check_dropin_content,

) {
  include profile_slurm::crons
  include profile_slurm::files
  include profile_slurm::id_check
  include profile_slurm::scheduler::firewall
  include systemd

  $dependencies.each | $dependency | {
    $configure_after_dependencies.each | $dependent | {
      $dependency -> $dependent
    }
  }

  # modify the slurmctld systemd unit file so that it
  # will only start up if the receipt file from
  # profile_slurm::id_check exists
  systemd::dropin_file { 'slurmctld-id_check.conf':
    content => $slurmctld_id_check_dropin_content,
    unit    => 'slurmctld.service',
  }
}
