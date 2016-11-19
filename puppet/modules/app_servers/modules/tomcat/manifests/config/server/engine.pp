define tomcat::config::server::engine (
  $default_host,
  $catalina_base                     = undef,
  $background_processor_delay        = undef,
  $background_processor_delay_ensure = 'present',
  $class_name                        = undef,
  $class_name_ensure                 = 'present',
  $engine_name                       = undef,
  $jvm_route                         = undef,
  $jvm_route_ensure                  = 'present',
  $parent_service                    = 'Catalina',
  $start_stop_threads                = undef,
  $start_stop_threads_ensure         = 'present',
  $server_config                     = undef,
) {
  include tomcat
  $_catalina_base = pick($catalina_base, $::tomcat::catalina_home)
  tag(sha1($_catalina_base))

  if versioncmp($::augeasversion, '1.0.0') < 0 {
    fail('Server configurations require Augeas >= 1.0.0')
  }

  validate_re($background_processor_delay_ensure, '^(present|absent|true|false)$')
  validate_re($class_name_ensure, '^(present|absent|true|false)$')
  validate_re($jvm_route_ensure, '^(present|absent|true|false)$')
  validate_re($start_stop_threads_ensure, '^(present|absent|true|false)$')

  if $engine_name {
    $_name = $engine_name
  } else {
    $_name = $name
  }

  $base_path = "Server/Service[#attribute/name='${parent_service}']/Engine"

  $_name_change = "set ${base_path}/#attribute/name ${_name}"
  $_default_host = "set ${base_path}/#attribute/defaultHost ${default_host}"

  if $background_processor_delay_ensure =~ /^(absent|false)$/ {
    $_background_processor_delay = "rm ${base_path}/#attribute/backgroundProcessorDelay"
  } elsif $background_processor_delay {
    $_background_processor_delay = "set ${base_path}/#attribute/backgroundProcessorDelay ${background_processor_delay}"
  } else {
    $_background_processor_delay = undef
  }

  if $class_name_ensure =~ /^(absent|false)$/ {
    $_class_name = "rm ${base_path}/#attribute/className"
  } elsif $class_name {
    $_class_name = "set ${base_path}/#attribute/className ${class_name}"
  } else {
    $_class_name = undef
  }

  if $jvm_route_ensure =~ /^(absent|false)$/ {
    $_jvm_route = "rm ${base_path}/#attribute/jvmRoute"
  } elsif $jvm_route {
    $_jvm_route = "set ${base_path}/#attribute/jvmRoute ${jvm_route}"
  } else {
    $_jvm_route = undef
  }

  if $start_stop_threads_ensure =~ /^(absent|false)$/ {
    $_start_stop_threads = "rm ${base_path}/#attribute/startStopThreads"
  } elsif $start_stop_threads {
    $_start_stop_threads = "set ${base_path}/#attribute/startStopThreads ${start_stop_threads}"
  } else {
    $_start_stop_threads = undef
  }

  if $server_config {
    $_server_config = $server_config
  } else {
    $_server_config = "${_catalina_base}/conf/server.xml"
  }

  $changes = delete_undef_values([$_name_change, $_default_host, $_background_processor_delay, $_class_name, $_jvm_route, $_start_stop_threads])

  augeas { "${_catalina_base}-${parent_service}-engine":
    lens    => 'Xml.lns',
    incl    => $_server_config,
    changes => $changes,
  }
}
