class sys11graphite::profile::mysql(
  $mysql_root_password,
  $mysql_db_name,
  $mysql_db_password,
) {
  class { '::mysql::server':
    #old_root_password => $mysql_root_password,
    root_password     => $mysql_root_password,
    #require          => [Mount['/var/lib/mysql'], Exec['copy tmp root-my.cnf to root-my.cnf']],
  }

  mysql::db { graphite:
    user     => $mysql_db_name,
    password => $mysql_db_password,
    host     => 'localhost',
    require  => Class['mysql::server'],
  }

}
