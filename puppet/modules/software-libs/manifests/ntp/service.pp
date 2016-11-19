class third_party::ntp::service {
  service { "ntpd":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Class["third_party::ntp::package"]
  }
}
