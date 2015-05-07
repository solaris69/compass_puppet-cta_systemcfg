class cta_systemcfg::puppetconf (
  $masterserver     = hiera('masterserver','localhost'),
  $masterserverport = hiera('masterserverport','8140'),
  $caserver         = hiera('caserver','localhost'),
  $runinterval      = hiera('runinterval','30m')
) {
  case $::osfamily {
    'windows': {
      $programdata = $::kernelmajversion ? {
        '5.2'   => 'C:/Documents and Settings/All Users/Application Data',
        default => 'C:/ProgramData',
      }
      $puppet_conf = "${programdata}/PuppetLabs/puppet/etc/puppet.conf"

      file { $puppet_conf:
        ensure  => present,
        content => template('cta_systemcfg/puppet.conf.erb'),
      }
    }
    default: { fail("${::osfamily} is not a supported platform.") }
  }
}