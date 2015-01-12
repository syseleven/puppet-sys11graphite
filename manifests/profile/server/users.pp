class sys11graphite::profile::server::users(
  $superusers = false,
) {
  define create_superuser() {
    notify{'TBD':}
  }
  file {'/opt/graphite/webapp/graphite/create_superuser.py':
    ensure => file,
    mode   => '0555',
    source => "puppet:///modules/$module_name/create_superuser.py",
    } ~>

  # init database mysql -e 'drop database graphite; create database graphite'; { echo  'no'; } | python /opt/graphite/webapp/graphite/manage.py syncdb
  exec {'create db and superuser':
    command     => 'python /opt/graphite/webapp/graphite/manage.py syncdb; /opt/graphite/webapp/graphite/create_superuser.py root tf-platform@syseleven.de Ofoo9ohf6vie || exit 0',
    provider    => 'shell',
    refreshonly => true,
  }

}
