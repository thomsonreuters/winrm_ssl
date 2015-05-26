Puppet Module to setup WinRM over HTTPS with Puppet Agent's certificates
--

Examples
--

    class { winrm:
    }

    class { winrm:
      maxmemorypershellmb => 5120,
      maxtimeoutms        => 600000,
    }

    class { winrm:
      auth_basic     => false,
      disable_http   => false,
      manage_service => false,
    }
