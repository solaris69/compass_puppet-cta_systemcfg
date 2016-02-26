class cta_systemcfg::useraccount (
  $username   = hiera('username'),
  $password   = hiera('password'),
) {
  case $::osfamily {
    'windows': {
      user { $username:
        ensure     => present,
        groups     => 'Administrators',
        password   => $password,
        home       => "C:\\Users\\${username}",
        managehome => true,
      }
      # Ensure AutoLogon is enabled
      $logonKey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
      registry::value { 'AutoAdminLogon':
        key  => $logonKey,
        type => 'string',
        data => '1',
      }
      registry::value { 'DefaultUserName':
        key  => $logonKey,
        type => 'string',
        data => $username,
      }
      registry::value { 'DefaultPassword':
        key  => $logonKey,
        type => 'string',
        data => $password,
      }
      registry_value { "${logonKey}\\AutoLogonCount":
        ensure => absent,
      }
    }
    default: { fail("${::osfamily} is not a supported platform.") }
  }
}