class sys11graphite::profile::server::dbbackup (
  # Database dumps go here
  $graphite_db_dumpdir_instance = '/root/dumps',
  $graphite_db_dumpdir_volume   = '/mnt/vdb/dumps',
  # execute dump at this cron timespec
  $graphite_db_dump_minute   = 0,
  $graphite_db_dump_hour     = 1,
  $graphite_db_dump_monthday = '*',
  $graphite_db_dump_month    = '*',
  $graphite_db_dump_weekday  = '*',
) {

  # We will put database dumps here
  file { "${graphite_db_dumpdir_instance}":
    ensure => directory,
    mode   => '0711',
    owner  => 'root',
    group  => 'root',
  } -> 

  # We will put database dumps here
  file { "${graphite_db_dumpdir_volume}":
    ensure => directory,
    mode   => '0711',
    owner  => 'root',
    group  => 'root',
  } -> 

  # template using $graphite_db_dumpdir
  file { '/usr/local/bin/database-dump':
    ensure  => file,
    mode    => '0555',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/database-dump.erb"),
  } ->

  cron { 'database-dump':
    command     => '/usr/local/bin/database-dump',
    environment => 'PATH=/bin:/usr/bin:/usr/sbin:/usr/local/bin',
    user        => 'root',
    minute      => $graphite_db_dump_minute,
    hour        => $graphite_db_dump_hour,
    monthday    => $graphite_db_dump_monthday,
    month       => $graphite_db_dump_month,
    weekday     => $graphite_db_dump_weekday,
  }
}
