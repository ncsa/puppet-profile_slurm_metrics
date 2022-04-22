# @summary Setup underlying storage for slurm scheduler
#
# @param require_storage
#   Optionally list resources (e.g., services) that require storage
#   in order to function.

# @param storage_dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up Slurm on a scheduler. Should be in the form that would
#   be specified as a requirement ("before") various Slurm scheduler
#   resources, e.g.:
#     Lvm::Logical_volume::mysql
#     Lvm::Logical_volume::slurm
#
# @example
#   include profile_slurm::scheduler::storage
class profile_slurm::scheduler::storage (

  Array[String]  $require_storage,
  Array[String]  $storage_dependencies,

){

  $storage_dependencies.each | $dependency |
  {
    $require_storage.each | $dependent |
    {
#    $mount -> Service['slurmctld']
#    $mount -> Service['slurmdbd']
      $dependency -> $dependent
    }
  }

}
