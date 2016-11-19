
class tomcat (
  $catalina_home       = $::tomcat::params::catalina_home,
  $user                = $::tomcat::params::user,
  $group               = $::tomcat::params::group,
  $install_from_source = true,
  $purge_connectors    = false,
  $purge_realms        = false,
  $manage_user         = true,
  $manage_group        = true,
) inherits ::tomcat::params {
  validate_bool($install_from_source)
  validate_bool($purge_connectors)
  validate_bool($purge_realms)
  validate_bool($manage_user)
  validate_bool($manage_group)

  case $::osfamily {
    'windows','Solaris','Darwin': {
      fail("Unsupported osfamily: ${::osfamily}")
    }
    default: { }
  }
}
