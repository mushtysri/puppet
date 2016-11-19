define tomcat::config::server::realm (
  $catalina_base         = undef,
  $class_name            = $name,
  $realm_ensure          = 'present',
  $parent_service        = 'Catalina',
  $parent_engine         = 'Catalina',
  $parent_host           = undef,
  $parent_realm          = undef,
  $additional_attributes = {},
  $attributes_to_remove  = [],
  $purge_realms          = undef,
  $server_config         = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))
  $_purge_realms = pick($purge_realms, $::tomcat::purge_realms)

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }
  validate_re($realm_ensure, '^(present|absent|true|false)$')
  validate_hash($additional_attributes)
  validate_array($attributes_to_remove)
  validate_bool($_purge_realms)

  if $_purge_realms and ($realm_ensure =~ /^(absent|false)$/) {
    fail('$realm_ensure must be set to \'true\' or \'present\' to use $purge_realms')
  }

  if $_purge_realms {
    # Perform deletions in reverse depth order as workaround for
    # https://github.com/hercules-team/augeas/issues/319
    $__purge_realms = [
      'rm //Realm//Realm',
      'rm //Context//Realm',
      'rm //Host//Realm',
      'rm //Engine//Realm',
      'rm //Server//Realm',
    ]
  } else {
    $__purge_realms = undef
  }

  $engine_path = "Server/Service[#attribute/name='${parent_service}']/Engine[#attribute/name='${parent_engine}']"

  # The Realm may be nested under a Host element.
  if $parent_host {
    $host_path = "${engine_path}/Host[#attribute/name='${parent_host}']"
  } else {
    $host_path = $engine_path
  }

  # The Realm could also be nested under another Realm element if the parent realm is a CombinedRealm.
  if $parent_realm {
    $path = "${host_path}/Realm[#attribute/className='${parent_realm}']/Realm"
  }
  else {
    $path = "${host_path}/Realm"
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  if $realm_ensure =~ /^(absent|false)$/ {
    $changes = "rm ${path}[#attribute/className='${class_name}']"
  }
  else {

    $_class_name = "set ${path}[#attribute/className='${class_name}']/#attribute/className ${class_name}"

    if ! empty($additional_attributes) {
      $_additional_attributes = suffix(prefix(join_keys_to_values($additional_attributes, " '"), "set ${path}[#attribute/className='${class_name}']/#attribute/"), "'")
    } else {
      $_additional_attributes = undef
    }
    if ! empty(any2array($attributes_to_remove)) {
      $_attributes_to_remove = prefix(any2array($attributes_to_remove), "rm ${path}[#attribute/className='${class_name}']/#attribute/")
    } else {
      $_attributes_to_remove = undef
    }

    $changes = delete_undef_values(flatten([ $__purge_realms, $_class_name, $_additional_attributes, $_attributes_to_remove ]))
  }

  augeas { "${_catalina_base}-${parent_service}-${parent_engine}-${parent_host}-${parent_realm}-realm-${class_name}":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }

}
