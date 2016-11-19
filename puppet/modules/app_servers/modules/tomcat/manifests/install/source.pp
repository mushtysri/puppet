
define tomcat::install::source (
  $catalina_home,
  $source_url,
  $source_strip_first_dir,
  $user,
  $group,
  $manage_user,
  $manage_group,
) {
  tag(sha1($catalina_home))
  include staging

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $source_strip_first_dir {
    $_strip = 1
  }

  $filename = regsubst($source_url, '.*/(.*)', '\1')

  if $manage_user {
    ensure_resource('user', $user, {
      ensure => present,
      gid    => $group,
    })
  }
  if $manage_group {
    ensure_resource('group', $group, {
      ensure => present,
    })
  }
  file { $catalina_home:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  ensure_resource('staging::file',$filename, {
    source => $source_url,
  })

  staging::extract { "${name}-${filename}":
    source  => "${::staging::path}/tomcat/${filename}",
    target  => $catalina_home,
    require => Staging::File[$filename],
    unless  => "test \"\$(ls -A ${catalina_home})\"",
    user    => $::tomcat::user,
    group   => $::tomcat::group,
    strip   => $_strip,
  }
}
