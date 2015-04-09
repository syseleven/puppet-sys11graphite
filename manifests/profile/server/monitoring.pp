class sys11graphite::profile::server::monitoring (
  $monitoring       = hiera('sys11stack::monitoring', false),
) {
  case $monitoring {
    'sensu':  {
      ensure_packages(['nagios-plugins-standard']) # needed for check_mysql

      sensu::check{ 'http_80':
        command => 'PATH=\$PATH:/usr/lib/nagios/plugins check_http -H localhost'
      }

      sensu::check{ 'carbon_cache':
        command => 'PATH=\$PATH:/usr/lib/nagios/plugins check_procs -a carbon-cache -c 1:2'
      }

      sensu::check{ 'memcache':
        command => 'PATH=\$PATH:/usr/lib/nagios/plugins check_procs -a memcached -c 1:2'
      }

      sensu::check{ 'mysql':
        command => "PATH=\$PATH:/usr/lib/nagios/plugins check_mysql -H localhost -u root -p $sys11graphite::profile::server::mysql_root_password",
      }
    }
    false:  { }
    default: { fail("Only sensu monitoring supported ('$monitoring' given)") }
  }
}

