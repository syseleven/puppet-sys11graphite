class sys11graphite::profile::setup_volume() {

  require sys11graphite::profile::tools

  exec { "mkfs-vdb":
    command => "mkfs.xfs /dev/vdb",
    path    => ['/sbin/', '/usr/sbin/'],
    unless  => "xfs_admin -l /dev/vdb",
  } ->
  file { '/mnt/vdb':
    ensure => directory,
  } ->
  mount { '/mnt/vdb': 
    ensure  => mounted, 
    device  => '/dev/vdb', 
    fstype  => 'xfs', 
    options => 'rw,nobootwait', 
  } 

}
