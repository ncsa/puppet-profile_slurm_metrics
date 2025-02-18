# @summary Creates a mailprog.sh script that can be used as MailProg in slurm.conf.
#
# Creates a mailprog.sh script that can be used as MailProg in slurm.conf. MailProg
# must still be set in slurm.conf using the slurm Puppet module.
#
# @param sendas_address
# Email address that should be used to send email (the FROM address).
# THIS PARAMETER MUST BE DEFINED TO CREATE THE SCRIPT!
#
# @example
#   include profile_slurm::scheduler::mailprog
class profile_slurm::scheduler::mailprog (
  $sendas_address,
) {
  # create the mailprog.sh script
  if $sendas_address {
    file { '/etc/slurm/mailprog.sh':
      ensure  => file,
      content => epp( 'profile_slurm/mailprog.sh.epp' ),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }
}
