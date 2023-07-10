# @summary Add a backup job to backup slurm data. 
# slurmdbd should be backed up via the mysql profile
#
# @param locations
#   files and directories that are to be backed up.
#
class profile_slurm::scheduler::backup (

  Array[String]     $locations,

) {
  if ( lookup('profile_backup::client::enabled') ) {
    profile_backup::client::add_job { 'slurm':
      paths => $locations,
    }
  }
}
