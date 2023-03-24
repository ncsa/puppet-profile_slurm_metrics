# @summary Setup firewall on slurm client
#
# @param slurmd_port
#   Destination ports that need to be open for the slurmd service
#
# @param sources
#   Array of CIDRs that need to be open for the slurmd service
#
# @example
#   include profile_slurm::client::firewall
class profile_slurm::client::firewall (
  Integer        $slurmd_port,
  Array[String]  $sources,
) {
  $sources.each | $source | {
    firewall { "100 allow ${source} access to slurmd":
      proto  => 'tcp',
      dport  => $slurmd_port,
      source => $source,
      action => 'accept',
    }
  }
}
