define tomcat::config::context::resource (
  $ensure                = 'present',
  $resource_name         = $name,
  $resource_type         = undef,
  $catalina_base         = $::tomcat::catalina_home,
  $additional_attributes = {},
  $attributes_to_remove  = [],
) {
  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($ensure, '^(present|absent|true|false)$')

  if $resource_name {
    $_resource_name = $resource_name
  } else {
    $_resource_name = $name
  }

  $base_path = "Context/Resource[#attribute/name='${_resource_name}']"

  if $ensure =~ /^(absent|false)$/ {
    $changes = "rm ${base_path}"
  } else {
    $set_name = "set ${base_path}/#attribute/name ${_resource_name}"
    if $resource_type {
      $set_type = "set ${base_path}/#attribute/type ${resource_type}"
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


    $changes = delete_undef_values(flatten([
      $set_name,
      $set_type,
      $set_additional_attributes,
      $rm_attributes_to_remove,
    ]))
  }

  augeas { "context-${catalina_base}-resource-${name}":
    lens    => 'Xml.lns',
    incl    => "${catalina_base}/conf/context.xml",
    changes => $changes,
  }
}
