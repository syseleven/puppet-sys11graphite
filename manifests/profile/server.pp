class sys11graphite::profile::server(
 $mysql_root_password = 'mysql_root_secure_Ifil8shaqu6m',
) {

  include sys11graphite::profile::server::monitoring

  class {'::memcached':
  }

  file {'/var/lib/mysql':
    ensure => directory,
  }
  mount { '/var/lib/mysql': 
    ensure  => mounted, 
    device  => '/mnt/vdb/mysql', 
    fstype  => 'none', 
    options => 'rw,bind', 
    require => File['/var/lib/mysql'],
  } 

  # needed when /var/lib/mysql already has data in it
  file { "/root/.my.cnf.temp":
    owner => 'root',
    mode => '0600',
    content => "
[client]
user=root
host=localhost
password='$mysql_root_password'
"
} ~>
exec { 'copy tmp root-my.cnf to root-my.cnf':
  command => 'cp /root/.my.cnf.temp /root/.my.cnf',
  path    => '/bin:/usr/bin',
  refreshonly => true,
}

class { '::mysql::server':
  root_password => $mysql_root_password,
  #override_options => { 'mysqld' => { 'datadir' => '/mnt/vdb/mysql'} },
  require => [Mount['/var/lib/mysql'], Exec['copy tmp root-my.cnf to root-my.cnf']],
}

mysql::db { graphite:
  user     => 'graphite',
  password => 'graphite_db_password_moohoo_secret',
  host     => 'localhost',
  require  => Class['mysql::server'],
}


class {'::graphite':
  gr_web_servername         => 'graphite.sys11.net',
  # TODO
  gr_django_db_engine       => 'django.db.backends.mysql',
  gr_django_db_name         => 'graphite',
  gr_django_db_user         => 'graphite',
  gr_django_db_password     => 'graphite_db_password_moohoo_secret',
  gr_django_db_host         => 'localhost',
  gr_django_db_port         => '3306',
  gr_max_creates_per_minute => '5000',
  gr_memcache_hosts         => ['localhost:11211'],
  secret_key                => 'graphite_secret_for_real',
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
  require => Class['memcached'],
}

file {'/opt/graphite/webapp/graphite/user.py':
  ensure => file,
  mode => 555,
  source => "puppet:///modules/$module_name/user.py",
  } ~>
  # init database mysql -e 'drop database graphite; create database graphite'; { echo  'no'; } | python /opt/graphite/webapp/graphite/manage.py syncdb
  exec {'create db and superuser':
    command => 'python /opt/graphite/webapp/graphite/manage.py syncdb; /opt/graphite/webapp/graphite/user.py root tf-platform@syseleven.de Ofoo9ohf6vie || exit 0',
    provider => 'shell',
    refreshonly => true,
  }
}
