# @summary Configure the telegraf collection script slurm_accounting_stats
#
# @param enable
#   Enables the telegraf collection script slurm_accounting_stats
#
# @param interval
#   How often to run the slurm_accounting_stats telegraf script
#
# @param timeout
#   Timeout for the slurm_accounting_stats telegraf script
#
# @example
#   include profile_slurm::telegraf::slurm_accounting_stats
class profile_slurm::telegraf::slurm_accounting_stats (
  Boolean $enable,
  String $interval,
  String $timeout,
){

  $script_base_name = 'slurm_accounting_stats'
  $script_path = lookup("${module_name}::telegraf::telegraf::script_path")
  $slurm_telegraf_enabled = lookup("${module_name}::telegraf::telegraf::enable")

  if ($enable) and ($slurm_telegraf_enabled) {
    $ensure_parm = 'present'
  } else {
    $ensure_parm = 'absent'
  }

  $script_conf = {
    source_path => "${script_path}/slurm_config",
  }

  file { "${script_path}/${script_base_name}.sh":
    ensure  => $ensure_parm,
    content => epp("${module_name}/${script_base_name}.sh.epp", $script_conf),
    mode    => '0750',
    owner   => 'root',
    group   => 'telegraf',
  }

  $telegraf_conf = {
    'command'  => "${script_path}/${script_base_name}.sh",
    'interval' => $interval,
    'timeout'  => $timeout,
  }

  file { "/etc/telegraf/telegraf.d/${script_base_name}.conf":
    ensure  => $ensure_parm,
    content => epp( "${module_name}/telegraf_conf.epp", $telegraf_conf),
    mode    => '0640',
    owner   => 'root',
    group   => 'telegraf',
    notify  => Service['telegraf'],
  }

}
