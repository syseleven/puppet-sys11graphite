class sys11graphite::profile::server(
  $mysql_root_password = 'mysql_root_secure_Ifil8shaqu6m',
  $memcache_host = false,
  $memcache_port = '11211',
  $graphite_secret_key,
  $mysql_host = false,
  $mysql_db_user,
  $mysql_db_password,
  $mysql_db_name
) {

  require sys11graphite::profile::setup_volume
  include sys11graphite::profile::server::monitoring

  if ! $memcache_host  {
    include sys11graphite::profile::memcached

    $memcache_host_real = 'localhost'
    $graphite_require = Class['memcached']
  } else {
    $memcache_host_real = $memcache_host
  }


  if ! $mysql_host {
    include sys11graphite::profile::mysql

    $mysql_host_real = 'localhost'
  } else {
    $mysql_host_real = $mysql_host
  }


  # TODO include user
  # TODO include mysql



  class {'::graphite':
    gr_web_servername         => 'graphite.sys11.net',
    gr_django_db_engine       => 'django.db.backends.mysql',
    gr_django_db_name         => $mysql_db_name,
    gr_django_db_user         => $mysql_db_user,
    gr_django_db_password     => $mysql_db_password,
    gr_django_db_host         => $mysql_host_real,
    gr_django_db_port         => '3306',
    gr_max_creates_per_minute => '5000',
    gr_memcache_hosts         => ["$memcache_host_real:$memcache_port"],
    secret_key                => $graphite_secret_key,
    gr_storage_schemas        =>
    [
      {
        name       => 'carbon',
        pattern    => '^carbon\.',
        retentions => '1m:90d'
      },
      {
        name       => 'default',
        pattern    => '.*',
        retentions => '1m:7d,5m:2y'
      }
    ],

    gr_storage_aggregation_rules =>

    {
      '00_min'         => { pattern => '\.min$',   factor => '0.1', method => 'min' },
      '01_max'         => { pattern => '\.max$',   factor => '0.1', method => 'max' },
      '02_sum'         => { pattern => '\.count$', factor => '0.1', method => 'sum' },
      '99_default_avg' => { pattern => '.*',       factor => '0.5', method => 'average'}
    },
  require => $graphite_require,
}

}
