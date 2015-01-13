class sys11graphite::profile::server::users(
  $superusers = false,
) {
  define create_superuser($superusers) {
    $email = $superusers[$name]['email']
    $password = $superusers[$name]['password']
    exec {"create superuser $name":
      command     => "/opt/graphite/webapp/graphite/create_superuser.py $name  $email $password || exit 0",
      provider    => 'shell',
      #refreshonly => true,
    }
  }

  if $superusers {
    file {'/opt/graphite/webapp/graphite/create_superuser.py':
      ensure => file,
      mode   => '0555',
      source => "puppet:///modules/$module_name/create_superuser.py",
    } 

    $superusers_keys = keys($superusers)
    create_superuser { $superusers_keys:
      superusers =>  $superusers,
    }
  }
}
