class cta_systemcfg (
  $timezone   = hiera('timezone'),
  $ntpservers = hiera('ntpservers'),
  $username   = hiera('username'),
  $password   = hiera('password'),
  $active_theme = hiera('active_theme'),
) {
  case $::osfamily {
    'windows': {
      # Set Power configuration
      exec { 'powercfg':
        path     => $::path,
#        command  => template('cta_systemcfg/powercfg.ps1'),
#        unless   => template('cta_systemcfg/check_powercfg.ps1'),
        command  => file('cta_systemcfg/powercfg.ps1'),
        unless   => file('cta_systemcfg/check_powercfg.ps1'),
        provider => powershell,
      }

      # Set Timezone to UTC and configure NTP servers
      exec { 'set timezone':
        path     => $::path,
        command  => "& tzutil /s \"${timezone}\"",
        unless   => "if ($(tzutil /g) -ne '${timezone}') { exit 1 }",
#        provider => powershell,
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

      # Disable RDP connections
      $rdp_regkey = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server'
      registry_key { $rdp_regkey:
        ensure => present,
      }
      ->
      registry_value { "${rdp_regkey}\\fDenyTSConnections":
        ensure => present,
        type   => 'dword',
        data   => '1',
      }

      ## Set Visual Effects settings performance to Best
      exec { 'set VisualFXSetting to Best Performance':
        path     => $::path,
        command  => template('cta_systemcfg/set_visual_perf_registry.ps1.erb'),
        unless   => template('cta_systemcfg/check_visual_perf_registry.ps1.erb'),
        provider => powershell,
      }

      exec { 'set UserPreferencesMask to Best Performance':
        path     => $::path,
        command  => template('cta_systemcfg/set_controlpanel_mask.ps1.erb'),
        unless   => template('cta_systemcfg/check_controlpanel_mask.ps1.erb'),
        provider => powershell,
      }

      # # Set Active Theme to Classic (0) for Win 7
      # if $::operatingsystemrelease == '7' {
      #   exec { 'set current Active Theme':
      #     path     => $::path,
      #     command  => template('cta_systemcfg/set_active_theme.ps1.erb'),
      #     unless   => template('cta_systemcfg/check_active_theme.ps1.erb'),
      #     provider => powershell,
      #   }
      # }

      # Ensure boot to desktop for Win 8.0
      if $::operatingsystemrelease == '8' {
        file { 'bootToDesktopWin8':
          ensure => present,
          path   => 'C:/Users/Administrator/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/w8_bootToDesktopScript.scf',
          source => 'puppet:///modules/cta_systemcfg/w8_bootToDesktopScript.scf',
        }
      }

      # Disable Windows Error Reporting
      $wer_regkey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting'
      registry_key { $wer_regkey:
        ensure => present,
      }
      ->
      registry_value { "${wer_regkey}\\Disabled":
        ensure => present,
        type   => 'dword',
        data   => '1',
      }

      # Disable Link-local Multicast Name Resolution
      $llmnr_regkey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
      registry_key { $llmnr_regkey:
        ensure => present,
      }
      ->
      registry_value { "${llmnr_regkey}\\EnableMulticast":
        ensure => present,
        type   => 'dword',
        data   => '0',
        notify => Exec['GPupdate for Windows Update'],
      }
      # ~>
      # reboot { 'reboot after disabling LLMNR':
      #   apply   => 'finished',
      #   message => 'Reboot after disabling LLMNR',
      # }

      # Disable Windows Automatic Update
      $wau_regkey = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
      registry_key { $wau_regkey:
        ensure => present,
      }
      ->
      registry_value { "${wau_regkey}\\NoAutoUpdate":
        ensure => present,
        type   => 'dword',
        data   => '1',
        notify => Exec['GPupdate for Windows Update'],
      }
      ->
      registry_value { "${wau_regkey}\\AUOptions":
        ensure => absent,
        notify => Exec['GPupdate for Windows Update'],
      }
      ->
      service { 'wuauserv':
        ensure => 'stopped',
        enable => false,
      }

      # Remove GPO files for Machine. Group Policies should be managed by registry keys, and never by GPO files.
      file { 'C:/Windows/System32/GroupPolicy/Machine/Registry.pol':
        ensure             => absent,
      }
      ~>
      exec { 'GPupdate for Windows Update':
        command     => 'gpupdate /force',
        path        => $::path,
        refreshonly => true,
      }

    }
    default: { fail("${::osfamily} is not a supported platform.") }
  }
}
