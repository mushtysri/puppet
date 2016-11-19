class webservers::nginx::config {
  if $host_protocol == "https" {
    $nginx_config_file = "webservers/nginx/https_nginx.conf.erb"
  } else {
    $nginx_config_file = "webservers/nginx/http_nginx.conf.erb"
  }

  file { "/etc/nginx/nginx.conf":
    ensure  => "present",
    content => template($nginx_config_file),
    owner   => root,
    group   => root,
    mode    => 644,
    require => Class["webservers::nginx::package"],
    notify  => Class["webservers::nginx::service"]
  }
}
