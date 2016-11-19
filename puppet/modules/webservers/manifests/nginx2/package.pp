class webservers::nginx::package {
# install nginx version depends on os version.
  if $operatingsystemrelease =~ /6./ {
    $nginx_version = "1.6.2-1.el6.ngx"
  } elsif $operatingsystemrelease =~ /7./ {
    $nginx_version = "1.8.0-1.el7.ngx"
  }

  package { "nginx":
    ensure  => $nginx_version,
    require => Class["webservers::nginx::repo"]
  }
}
