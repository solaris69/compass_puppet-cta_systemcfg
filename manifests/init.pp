class cta_systemcfg (
  $timezone   = hiera('timezone'),
  $ntpservers = hiera('ntpservers'),
  $username   = hiera('username'),
  $password   = hiera('password'),
) {
  case $::osfamily {
    'windows': {
      # Power configuration
      exec { 'powercfg':
        path     => $::path,
        command  => template('cta_systemcfg/powercfg.ps1'),
        unless   => template('cta_systemcfg/check_powercfg.ps1'),
        provider => powershell,
      }

      # Time zone
      exec { 'set timezone':
        path     => $::path,
        command  => "& tzutil /s \"${timezone}\"",
        unless   => "if ($(tzutil /g) -ne '${timezone}') { exit 1 }",
        provider => powershell,
      }
      ->
      class { 'winntp':
        ntp_server => join($ntpservers,',')
      }

      # Activating Windows license
      # $winlicensehash = hiera('winlicense')
      # $winlicense = $winlicensehash["Windows ${::operatingsystemrelease} ${::operatingsystemedition}"]
      # exec { 'windows licensing':
      #   path     => $::path,
      #   command  => template('cta_systemcfg/activate_winlicense.ps1.erb'),
      #   unless   => template('cta_systemcfg/check_winlicense.ps1.erb'),
      #   provider => powershell,
      # }

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

      # Ensure 'console' (aka active desktop) is directed on user's account session
      exec { 'redirect \'console\' session':
        path     => $::path,
        command  => template('cta_systemcfg/redirect_console_session.ps1.erb'),
        unless   => template('cta_systemcfg/check_current_session.ps1.erb'),
        provider => powershell,
      }

      # Ensure boot to desktop for Win 8.0
      if $::operatingsystemrelease == '8' {
        file { 'bootToDesktopWin8':
          ensure => present,
          path   => 'C:/Users/Administrator/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/w8_bootToDesktopScript.scf',
          source => 'puppet:///modules/cta_systemcfg/w8_bootToDesktopScript.scf',
        }
      }

    }
    default: { fail("${::osfamily} is not a supported platform.") }
  }
}