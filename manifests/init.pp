# == Class: winrm_ssl
#
# Setup WinRM over HTTPS utilising Puppet's certificates.
#
# === Parameters
#
#
# === Variables
#
#
# === Examples
#
#  class { winrm_ssl:
#  }
#
#  class { winrm_ssl:
#    maxmemorypershellmb => 5120,
#    maxtimeoutms        => 600000,
#  }
#
#  class { winrm_ssl:
#    auth_basic     => false,
#    disable_http   => false,
#    manage_service => false,
#  }
#
# === Authors
#
# Dhruv Ahuja <dhruv.ahuja@thomsonreuters.com>
#
# === Copyright
#
#
class winrm_ssl($auth_basic = true, $disable_http = true, $manage_service = true, $maxmemorypershellmb = 1024, $maxtimeoutms = 60000) {

  if $::kernel == 'windows' {

    $unless_script = template('winrm_ssl/unless.rb.erb')
    $create_script = template('winrm_ssl/create.rb.erb')

    exec{'winrm_create_listener_https':
      command     => "ruby -e '${create_script}'",
      path        => ["${::env_windows_installdir}\\sys\\ruby\\bin", $::path],
      environment => ["RUBYLIB=${::env_windows_installdir}\\puppet\\lib;${::env_windows_installdir}\\facter\\lib;${::env_windows_installdir}\\hiera\\lib", 'RUBYOPT=rubygems'],
      unless      => "ruby -e '${unless_script}'"
    }

    if ($disable_http) {
      exec {'winrm_delete_http':
        command => 'winrm.cmd delete winrm/config/listener?Address=*+Transport=HTTP',
        path    => ['c:/windows/system32'],
        onlyif  => "winrm.cmd enumerate winrm/config/listener | findstr /e /c:\"Transport = HTTP\"",
      }
    }
    else {
      exec {'winrm_create_http':
        command => 'winrm.cmd create winrm/config/listener?Address=*+Transport=HTTP',
        path    => ['c:/windows/system32'],
        unless  => "winrm.cmd enumerate winrm/config/listener | findstr /e /c:\"Transport = HTTP\"",
      }
    }

    if ($manage_service) {
      service {'winrm':
        ensure => running,
        enable => true,
      }
    }

    exec {'winrm_set_auth_basic':
      command => "winrm.cmd set winrm/config/service/auth @{Basic=\"${auth_basic}\"}",
      path    => ['c:/windows/system32'],
      unless  => "winrm.cmd get winrm/config/service/auth | findstr /e /c:\"Basic = ${auth_basic}\"",
    }

    exec {'winrm_set_maxmemorypershellmb':
      command => "winrm.cmd set winrm/config/winrs @{MaxMemoryPerShellMB=\"${maxmemorypershellmb}\"}",
      path    => ['c:/windows/system32'],
      unless  => "winrm.cmd get winrm/config/winrs | findstr /e /c:\"MaxMemoryPerShellMB = ${maxmemorypershellmb}\"",
    }

    exec {'winrm_set_maxtimeoutms':
      command => "winrm.cmd set winrm/config @{MaxTimeoutms=\"${maxtimeoutms}\"}",
      path    => ['c:/windows/system32'],
      unless  => "winrm.cmd get winrm/config | findstr /e /c:\"MaxTimeoutms = ${maxtimeoutms}\"",
    }

  } else {
    notify {'unsupported_os':
      message => "Not supported on kernel \"${::kernel}\". Skipping silently.",
    }
  }
}
