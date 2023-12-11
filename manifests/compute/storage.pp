# @summary Setup underlying storage for slurm compute nodes
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
#   E.g.: "Lvm::Logical_volume[local]"
#
# @example
#   include profile_slurm::compute::storage
#
class profile_slurm::compute::storage (

  Optional[String] $tmpfs_dir,
  Optional[String] $tmpfs_dir_refresh_command,
  Optional[String] $tmpfs_dir_refreshed_by,

) {
  # If we manage a tmpfs directory, ensure it prior to any resources defined
  # by profile_slurm::compute::configure_after_dependencies, and optionally refresh
  # (delete and recreate) the tmpfs directory.
  if $tmpfs_dir {
    # Optionally refresh the tmpfs directory.
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

    # Ensure the tmpfs_dir.
    file { $tmpfs_dir:
      ensure => 'directory',
      group  => 'root',
      mode   => '0755',
      owner  => 'root',
    }

    # Ensure that the tmpfs_dir is managed prior to other resources, e.g., slurmd.
    $dependents = lookup('profile_slurm::compute::configure_after_dependencies')
    $dependents.each | $dependent | {
      File[$tmpfs_dir] -> $dependent
    }
  }
}
