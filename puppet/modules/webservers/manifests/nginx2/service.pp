class webservers::nginx::service {
  service { "nginx":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Class["webservers::nginx::config"],
  }
}
