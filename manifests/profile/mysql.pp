class sys11graphite::profile::mysql() {
  # FIXME make this work properly
  # needed when /var/lib/mysql already has data in it
  file { '/root/.my.cnf.temp':
    owner   => 'root',
    mode    => '0600',
    content => "
[client]
user=root
host=localhost
password='$mysql_root_password'
"
  } ~>

  #  exec { 'copy tmp root-my.cnf to root-my.cnf':
  #  command     => 'cp /root/.my.cnf.temp /root/.my.cnf',
  #  path        => '/bin:/usr/bin',
  #  refreshonly => true,
  #}

  #override_options => { 'mysqld'                                                              => { 'datadir' => '/mnt/vdb/mysql'} },

  class { '::mysql::server':
    root_password => $mysql_root_password,
    #require       => [Mount['/var/lib/mysql'], Exec['copy tmp root-my.cnf to root-my.cnf']],
  }

  mysql::db { graphite:
    user     => 'graphite',
    password => 'graphite_db_password_moohoo_secret',
    host     => 'localhost',
    require  => Class['mysql::server'],
  }

}
