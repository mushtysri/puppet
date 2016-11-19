define tomcat::config::context::resourcelink (
  $ensure                = 'present',
  $catalina_base         = $::tomcat::catalina_home,
  $resourcelink_name     = $name,
  $resourcelink_type     = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Context configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  $base_path = "Context/ResourceLink[#attribute/name='${resourcelink_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $augeaschanges = "rm ${base_path}"
  } else {
    $set_name = "set ${base_path}/#attribute/name ${resourcelink_name}"
    if $resourcelink_type {
      $set_type = "set ${base_path}/#attribute/type ${resourcelink_type}"
    } else {
      $set_type = undef
    }

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

    $augeaschanges = delete_undef_values(flatten([
      $set_name,
      $set_type,
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-resourcelink-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $augeaschanges,
  }
}
