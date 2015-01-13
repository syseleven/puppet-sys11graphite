class sys11graphite::profile::setup_volume() {

  require sys11graphite::profile::tools

  exec { 'mkfs-vdb':
    command => 'mkfs.xfs /dev/vdb',
    path    => ['/sbin/', '/usr/sbin/'],
    unless  => 'xfs_admin -l /dev/vdb',
  } ->

  file { '/mnt/vdb':
    ensure => directory,
  } ->

  mount { '/mnt/vdb':
    ensure  => mounted,
    device  => '/dev/vdb',
    fstype  => 'xfs',
    options => 'rw,nobootwait',
  } ->

  file {'/var/lib/mysql':
    ensure => directory,
  } ->

  file { '/mnt/vdb/mysql':
    ensure => directory,
  } ->

  mount { '/var/lib/mysql':
    ensure  => mounted,
    device  => '/mnt/vdb/mysql',
    fstype  => 'none',
    options => 'rw,bind,nobootwait',
    require => File['/var/lib/mysql', '/mnt/vdb/mysql'],
    before  => Class['::mysql::server'],
  }


  file { '/mnt/vdb/storage':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  } ->

  file { '/opt/graphite/storage':
    target => '/mnt/vdb/storage',
    before => Class['::graphite'],
  }


  # dirty workaround for using an existing mysql installation with puppetlabs-mysql

 file { '/root/.my.cnf.old_instance':
    owner   => 'root',
    mode    => '0600',
    content => "
[client]
user=root
host=localhost
password='$mysql_root_password'
"
  } ->

 exec { 'copy tmp root-my.cnf to root-my.cnf':
   command => 'cp /root/.my.cnf.temp /root/.my.cnf',
   path    => '/bin:/usr/bin',
   unless  => 'mysql',
   before  => Class['::mysql::server'],
 }
}
