# @summary Setup firewall on slurm scheduler
#
# @param slurmctld_port
#   Destination port that need to be open for the slurmctld service
#
# @param slurmdbd_port
#   Destination port that need to be open for the slurmdbd service
#
# @param sources
#   Array of CIDRs that need to be open for the slurmctld and slurmdbd service
#
# @example
#   include profile_slurm::scheduler::firewall
class profile_slurm::scheduler::firewall (
  Integer        $slurmctld_port,
  Integer        $slurmdbd_port,
  Array[String]  $sources,
) {
  $sources.each | $source | {
    firewall { "100 allow ${source} access to slurmctld":
      proto  => 'tcp',
      dport  => $slurmctld_port,
      source => $source,
      action => 'accept',
    }

    firewall { "100 allow ${source} access to slurmdbd":
      proto  => 'tcp',
      dport  => $slurmdbd_port,
      source => $source,
      action => 'accept',
    }
  }
}
