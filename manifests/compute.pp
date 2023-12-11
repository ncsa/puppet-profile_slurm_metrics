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
# @example
#   include profile_slurm::compute
class profile_slurm::compute (

  Array[String]  $dependencies,
  Array[String]  $configure_after_dependencies,

) {
  include profile_slurm::compute::storage
  include profile_slurm::crons
  include profile_slurm::files

  $dependencies.each | $dependency | {
    $configure_after_dependencies.each | $dependent | {
      $dependency -> $dependent
    }
  }
}
