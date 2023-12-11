# @summary Configure slurmrestd service.
#
# Configure slurmrestd service.
#
# @param dependencies
#   Optionally list resources (e.g. mounts) that should be present before
#   setting up Slurm on a node running slurmrestd as a service. Should be
#   in the form that would be specified as a requirement ("before")
#   Service[slurmrestd]. If the node is also the scheduler it generally
#   makes sense to include "Service[slurmctld]".
#
# @param group_id
#   GID of the slurmrestd group.
#
# @param group_name
#   Name of the group for the slurmrestd service account.
#
# @param firewall_port
#   Port number for slurmrestd.
#
# @param firewall_sources
#   List of CIDRs to allow (can be empty).
#
# @param configure_after_dependencies
#   Optionally list resources (e.g., services) that require any of the
#   items from the $dependencies parameter in order to function.
#
# @param user_home
#   Home dir of the slurmrestd service account.
#
# @param user_id
#   UID of the slurmrestd service account.
#
# @param user_name
#   Name of the slurmrestd service account.
#
# @example
#   include profile_slurm::slurmrestd
#
class profile_slurm::slurmrestd (

  Array[String]  $dependencies,
  Integer        $group_id,
  String         $group_name,
  Integer        $firewall_port,
  Array          $firewall_sources,
  Array[String]  $configure_after_dependencies,
  String         $user_home,
  Integer        $user_id,
  String         $user_name,

) {
  group { $group_name:
    ensure => 'present',
    before => Class['slurm::common::install'],
    gid    => $group_id,
  }

  user { $user_name:
    ensure         => 'present',
    before         => Class['slurm::common::install'],
    uid            => $user_id,
    gid            => $group_id,
    forcelocal     => true,
    home           => $user_home,
    managehome     => false,
    password       => '!!',
    purge_ssh_keys => true,
    shell          => '/sbin/nologin',
    comment        => 'slurmrestd',
  }

  $firewall_sources.each | $source | {
    firewall { "100 allow ${source} access to slurmrestd":
      proto  => 'tcp',
      dport  => $firewall_port,
      source => $source,
      action => 'accept',
    }
  }

  $dependencies.each | $dependency | {
    $configure_after_dependencies.each | $dependent | {
      $dependency -> $dependent
    }
  }
}
