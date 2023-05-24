# @summary Support installation of arbitrary files.
#
# Support installation of arbitrary files.
#
# @param files
#   File resources.
#
# @example
#   include profile_slurm::files
class profile_slurm::files (
  Hash $files,
) {
  $file_defaults = {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
  ensure_resources('file', $files, $file_defaults )
}
