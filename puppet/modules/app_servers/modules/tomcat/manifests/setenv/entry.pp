
define tomcat::setenv::entry (
  $value,
  $ensure        = 'present',
  $catalina_home = undef,
  $config_file   = undef,
  $param         = $name,
  $quote_char    = undef,
  $order         = '10',
  $addto         = undef,
  # Deprecated
  $base_path     = undef,
) {
  include tomcat
  $_catalina_home = pick($catalina_home, $::tomcat::catalina_home)
  $home_sha = sha1($_catalina_home)
  tag($home_sha)

  Tomcat::Install <| tag == $home_sha |>
  -> Tomcat::Setenv::Entry[$name]

  if $base_path {
    warning('The $base_path parameter is deprecated; please use catalina_home or config_file instead')
    $_config_file = "${base_path}/setenv.sh"
  } else {
    $_config_file = $config_file ? {
      undef   => "${_catalina_home}/bin/setenv.sh",
      default => $config_file,
    }
  }

  if ! $quote_char {
    $_quote_char = ''
  } else {
    $_quote_char = $quote_char
  }

  if ! defined(Concat[$_config_file]) {
    concat { $_config_file:
      owner          => $::tomcat::user,
      group          => $::tomcat::group,
      ensure_newline => true,
    }
  }

  if $addto {
    $_content = inline_template('export <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char %> ; export <%= @addto %>="$<%= @addto %> $<%= @param %>"')
  } else {
    $_content = inline_template('export <%= @param %>=<%= @_quote_char %><%= Array(@value).join(" ") %><%= @_quote_char %>')
  }
  concat::fragment { "setenv-${name}":
    ensure  => $ensure,
    target  => $_config_file,
    content => $_content,
    order   => $order,
  }
}
