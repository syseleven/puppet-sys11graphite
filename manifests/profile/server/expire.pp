class sys11graphite::profile::server::expire (
  # Root of the directory containing your wsp files
  $whisper_datadir         = '/opt/graphite/storage/whisper';
  # delete whisper files not written to for 7 days
  $whisper_expire_days_delay = 7,
  # execute deletion at this cron timespec
  $whisper_expire_minute   = 5,
  $whisper_expire_hour     = 0,
  $whisper_expire_monthday = '*',
  $whisper_expire_month    = '*',
  $whisper_expire_weekday  = '*',
) {

  file { '/root/bin':
    ensure => directory,
    mode   => '0711',
    owner  => 'root',
    group  => 'root'
  } ->

  # template using $whisper_expire_days_delay and $whisper_datadir in generated cronjob
  file { '/root/bin/graphite-whisper-expire':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => template("${module_name}/graphite-whisper-expire.erb"),
  } ->

  cron { 'graphite-whisper-expire':
    command     => '/root/bin/graphite-whisper-expire',
    environment => 'PATH=/bin:/usr/bin:/usr/sbin',
    user        => 'www-data',
    minute      => $whisper_expire_minute,
    hour        => $whisper_expire_hour,
    monthday    => $whisper_expire_monthday,
    month       => $whisper_expire_month,
    weekday     => $whisper_expire_weekday
  }
}
