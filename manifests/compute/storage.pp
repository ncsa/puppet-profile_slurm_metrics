# @summary Setup underlying storage for slurm compute nodes
#
# @param require_storage
#   Optionally list resources (e.g., services) that require storage
#   in order to function.
#
# @param storage_dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up Slurm on a compute node. Should be in the form that would
#   be specified as a requirement ("before") various Slurm compute (slurmd)
#   resources, e.g.:
#     - "Lvm::Logical_volume::local"
#
# @param tmpfs_dir
#   Directory to create for job_container/tmpfs ("job /tmp" directory).
#   Created by File resource or Exec depending on value of
#   $tmpfs_dir_refeshed_by.
#   E.g.: "/local/slurmjobs"
#
# @param tmpfs_dir_refresh_command
#   Optional command that should refresh $tmpfs_dir. If not specified,
#   then "rm -rf ${tmpfs_dir}" will be used.
#  
# @param tmpfs_dir_refreshed_by
#   Resource which $tmpfs_dir requires and which should cause it to be
#   refreshed (removed and recreated). If this is NOT defined, and
#   $tmpfs_dir IS defined, then Puppet will simply ensure that $tmpfs_dir
#   exists. 
#   E.g.: "Lvm::Logical_volume['local']"
#
# @example
#   include profile_slurm::scheduler::storage
#
class profile_slurm::compute::storage (

  Array[String]    $require_storage,
  Array[String]    $storage_dependencies,
  Optional[String] $tmpfs_dir,
  Optional[String] $tmpfs_dir_refresh_command,
  Optional[String] $tmpfs_dir_refreshed_by,

){

  # Make sure that underlying storage dependencies (mounts, etc.)
  # are ensured prior to things that depend on them (e.g., services).
  $storage_dependencies.each | $dependency |
  {
    $require_storage.each | $dependent |
    {
      $dependency -> $dependent
    }
  }

  # If we manage a tmpfs directory, ensure it prior to $require_storage
  # resources, and optionally refresh (delete and recreate) the tmpfs directory.
  if $tmpfs_dir {
    if $tmpfs_dir_refreshed_by {
      # we have defined a resource that $tmpfs_dir depends on and
      # this resource ($tmpfs_dir_refreshed_by) is updated, $tmpfs_dir
      # will be removed and recreated

      if $tmpfs_dir_refresh_command {
        $refresh_command = $tmpfs_dir_refresh_command
      } else {
        $refresh_command = "rm -rf ${tmpfs_dir}"
      }

      exec { "refresh_${tmpfs_dir}":
        before      => File[$tmpfs_dir],
        command     => $refresh_command,
        path        => ['/bin', '/usr/bin', '/usr/sbin'],
        refreshonly => true,
        subscribe   => $tmpfs_dir_refreshed_by,
      }
    }

    # $tmpfs_dir doesn't depend on anything, just ensure it exists
    file { $tmpfs_dir:
      ensure => 'directory',
      group  => 'root',
      mode   => '0755',
      owner  => 'root',
    }
    $require_storage.each | $dependent |
    {
      File[$tmpfs_dir] -> $dependent
    }
  }

}
