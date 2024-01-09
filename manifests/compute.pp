# @summary Setup slurm config for slurm compute node
#
# @param dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up Slurm on a compute node. Should be in the form that would
#   be specified as a requirement ("before") various Slurm compute
#   resources, e.g.:
#     "Gpfs::Bindmount['/scratch']"
#     "Gpfs::Bindmount['/sw']"
#     "Gpfs::Bindmount['/u']"
#     "Gpfs::Nativemount['/cluster']"
#     "Lvm::Logical_volume[local]"
#     "Profile_lustre::Nativemount_resource['/projects']"
#     "Profile_lustre::Nativemount_resource['/taiga']"
#
# @param configure_after_dependencies
#   Optionally list resources (e.g., services) that require any of the
#   items from the $dependencies parameter in order to function.
#
# @param slurmd_id_check_dropin_content
#   Content for a systemd dropin file that ensures the service
#   will only start up if the receipt file from
#   profile_slurm::id_check exists.
#
# @example
#   include profile_slurm::compute
class profile_slurm::compute (

  Array[String]  $dependencies,
  Array[String]  $configure_after_dependencies,
  String         $slurmd_id_check_dropin_content,

) {
  include profile_slurm::compute::storage
  include profile_slurm::crons
  include profile_slurm::files
  include profile_slurm::id_check
  include systemd

  $dependencies.each | $dependency | {
    $configure_after_dependencies.each | $dependent | {
      $dependency -> $dependent
    }
  }

  # modify the slurmd systemd unit file so that it
  # will only start up if the receipt file from
  # profile_slurm::id_check exists
  systemd::dropin_file { 'slurmd-id_check.conf':
    content => $slurmd_id_check_dropin_content,
    unit    => 'slurmd.service',
  }
}
