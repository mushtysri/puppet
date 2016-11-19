class ports {
    tomcat::config::server::connector { 'default':
    catalina_base         => '/opt/tomcat8',
    port                  => '8081',
    protocol              => 'HTTP/1.1',
    additional_attributes => {
      'redirectPort' => '8443',
    }
  }
}
