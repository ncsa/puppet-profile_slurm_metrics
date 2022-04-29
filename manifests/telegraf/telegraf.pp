# @summary Sets up requirements for all telegraf checks
#
# @param enable
#   Used to enable or disable all slurm telegraf checks
#
# @param required_pkgs
#   String array of packages required for telegraf checks
#
# @param script_path
#   Path where telegraf scripts and supporting config files will go
#
# @param slurm_database
#   Slurm database to query
#
# @param slurm_job_table
#   Slurm job table to query
#
# @param slurm_password
#   Password for the slurm user account
#   Leave blank if using MySQL socket authentication
#
# @param slurm_path
#   Path to slurm bin
#
# @param slurm_username
#   Username for pulling slurm stats
#
# @example
#   include profile_slurm::telegraf::telegraf
class profile_slurm::telegraf::telegraf (

  Boolean $enable,
  Array[String] $required_pkgs,
  String $script_path,
  String $slurm_database,
  String $slurm_job_table,
  String $slurm_path,
  String $slurm_username,
  Optional[String] $slurm_password='',
){

  if ($enable) {
    $ensure_parm = 'present'

    if ($slurm_job_table.empty) {
      fail('This required value is not set: slurm_job_table')
    }

    ensure_packages( $required_pkgs )

  } else {
    $ensure_parm = 'absent'
  }

  file { $script_path :
    ensure => 'directory',
    owner  => 'root',
    group  => 'telegraf',
    mode   => '0750',
  }

  $slurm_config = {
    slurm_path => $slurm_path,
    username   => $slurm_username,
    password   => $slurm_password,
    database   => $slurm_database,
    job_table  => $slurm_job_table,
  }

  file { "${script_path}/slurm_config" :
    ensure  => $ensure_parm,
    content => epp("${module_name}/slurm_config.epp", $slurm_config),
    owner   => 'root',
    group   => 'telegraf',
    mode    => '0740',
  }

}
