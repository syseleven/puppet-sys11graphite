class sys11graphite::profile::server(
  $memcache_host = false,
  $memcache_port = '11211',
  $graphite_secret_key,
  $mysql_host = false,
  $mysql_root_password = false,
  $mysql_db_user = 'graphite',
  $mysql_db_password,
  $mysql_db_name = 'graphite',
  $superusers = false,
  $setup_volume = false,
  $gr_web_servername = $::fqdn,
  $gr_storage_schemas = [
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

    $gr_storage_aggregation_rules = {
      '00_min'         => { pattern => '\.min$',   factor => '0.1', method => 'min' },
      '01_max'         => { pattern => '\.max$',   factor => '0.1', method => 'max' },
      '02_sum'         => { pattern => '\.count$', factor => '0.1', method => 'sum' },
      '99_default_avg' => { pattern => '.*',       factor => '0.5', method => 'average'}
    },
) {

  if $setup_volume {
    require sys11graphite::profile::setup_volume
  }

  if ! $memcache_host  {
    include sys11graphite::profile::memcached

    $memcache_host_real = 'localhost'
    $graphite_require = Class['memcached']
  } else {
    $memcache_host_real = $memcache_host
  }


  if ! $mysql_host {
    if ! $mysql_root_password {
      fail('You need to specify a mysql root password in order to deploy own mysql installation!')
    }

    class { 'sys11graphite::profile::mysql':
      mysql_root_password => $mysql_root_password,
      mysql_db_name       => $mysql_db_name,
      mysql_db_password   => $mysql_db_password,
    }
    $mysql_host_real = 'localhost'
  } else {
    $mysql_host_real = $mysql_host
  }

  class {'::graphite':
    gr_web_servername            => $gr_web_servername,
    gr_django_db_engine          => 'django.db.backends.mysql',
    gr_django_db_name            => $mysql_db_name,
    gr_django_db_user            => $mysql_db_user,
    gr_django_db_password        => $mysql_db_password,
    gr_django_db_host            => $mysql_host_real,
    gr_django_db_port            => '3306',
    gr_max_creates_per_minute    => '5000',
    gr_memcache_hosts            => ["$memcache_host_real:$memcache_port"],
    secret_key                   => $graphite_secret_key,
    gr_storage_schemas           => $gr_storage_schemas,
    gr_storage_aggregation_rules => $gr_storage_aggregation_rules,
    require                      => $graphite_require,
  }

  # remove default vhosts to avoid collision
  file { ['/etc/apache2/sites-enabled/000-default', '/etc/apache2/sites-enabled/000-default.conf']:
    ensure  => absent,
    require => Package[$::graphite::params::apache_pkg],
    before  => Service[$::graphite::params::apache_service_name],
  }

  class { 'sys11graphite::profile::server::users':
    superusers => $superusers,
    require    => Class['::graphite'],
  }

  class { 'sys11graphite::profile::server::monitoring':
    require    => Class['::graphite'],
  }
}
