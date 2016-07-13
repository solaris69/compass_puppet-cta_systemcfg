class cta_systemcfg::puppetservice (
  $username = 'LocalSystem',
  $password = '',
  $interactive = false,
){
  case $::osfamily {
    'windows': {
      local_security_policy { 'Log on as a service':
        ensure       => 'present',
        policy_value => 'EVERYONE',
      }
      # Value 'NT_SERVICE\ALL_SERVICES' only works if there is two backslashes, but then the resource is not idempotent
      # Value '.\Administrator' does not work. It seems the module cannot find that user (same for any other users actually)
      file { 'c:/vc': ensure => directory }

      if $username == 'LocalSystem' {
        exec { 'set puppet service account':
          path     => $::path,
          command  => "& sc.exe config puppet obj= \".\\${username}\"",
          unless   => template('cta_systemcfg/check_puppetservice_startname.ps1.erb'),
          require  => Local_security_policy['Log on as a service'],
          provider => powershell,
        }
        if ($interactive) {
          exec { 'set puppet service interactive':
            path     => $::path,
            command  => '& sc.exe config puppet type= interact type= own',
            provider => powershell,
          }
          ~>
          reboot { 'reboot after puppet service configuration':
            apply   => 'immediately',
            message => 'Reboot after configuring puppet service',
          }
        }
        else {
          reboot { 'reboot after puppet service configuration':
            apply     => 'immediately',
            message   => 'Reboot after configuring puppet service',
            subscribe => Exec['set puppet service account'],
          }
        }
      }
      else {
        file{ 'c:/vc/check_puppetservice_startname.ps1': ensure => file, content => template('cta_systemcfg/check_puppetservice_startname.ps1.erb'), require => File['c:/vc']} ->
        exec { 'set puppet service account':
          path     => $::path,
          command  => "& sc.exe config puppet obj= \".\\${username}\" password= \"${password}\"",
          unless   => 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Executionpolicy Unrestricted -File c:/vc/check_puppetservice_startname.ps1',
          require  => Local_security_policy['Log on as a service'],
#          provider => powershell,
        }
        ~>
        reboot { 'reboot after puppet service configuration':
          apply   => 'immediately',
          message => 'Reboot after configuring puppet service',
        }
      }
    }
    default: { fail("${::osfamily} is not a supported platform.") }
  }
}
