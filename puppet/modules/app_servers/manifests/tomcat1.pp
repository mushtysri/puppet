class tomcat1 { 
tomcat::install { '/opt/tomcat8': 
  source_url => 'https://www.apache.org/dist/tomcat/tomcat-8/v8.5.4/bin/apache-tomcat-8.5.4.tar.gz',
                }
               
tomcat::instance { 'tomcat8': 
    catalina_home => '/opt/tomcat8',
    }
}
