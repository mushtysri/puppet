define tomcat::config::server::globalnamingresource (
  $catalina_base         = $::tomcat::catalina_home,
  $ensure                = 'present',
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $server_config         = undef,
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_re($catalina_base, '^.*[^/]$', '$catalina_base must not end in a /!')

  $base_path = "Server/GlobalNamingResources/Resource[#attribute/name='${name}']"

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${catalina_base}/conf/server.xml"
  }

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    if ! empty($additional_attributes) {
      $set_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${base_path}/#attribute/"), "'")
    } else {
      $set_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $rm_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${base_path}/#attribute/")
    } else {
      $rm_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "server-${catalina_base}-globalresource-${name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
