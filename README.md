Puppet Module to setup WinRM over HTTPS with Puppet Agent's certificates
--

Examples
--

    class { winrm_ssl:
    }

    class { winrm_ssl:
      maxmemorypershellmb => 5120,
      maxtimeoutms        => 600000,
    }

    class { winrm_ssl:
      auth_basic     => false,
      disable_http   => false,
      manage_service => false,
    }
