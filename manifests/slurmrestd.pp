# @summary Configure slurmrestd service.
#
# Configure slurmrestd service.
#
# @example
#   include profile_slurm::slurmrestd
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
# @param user_home
#   Home dir of the slurmrestd service account.
#
# @param user_id
#   UID of the slurmrestd service account.
#
# @param user_name
#   Name of the slurmrestd service account.
#
class profile_slurm::slurmrestd (

  Integer $group_id,
  String  $group_name,
  Integer $firewall_port,
  Array   $firewall_sources,
  String  $user_home,
  Integer $user_id,
  String  $user_name,

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
}
