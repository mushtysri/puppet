class webservers::nginx::repo {
  $repo = "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/debian/\$basearch/
gpgcheck=0
enabled=1
"
  file { "/etc/init.d/nginx.repo":
    ensure  => "present",
    content => $repo,
    owner   => root,
    group   => root,
    mode    => "644",
  }
}
