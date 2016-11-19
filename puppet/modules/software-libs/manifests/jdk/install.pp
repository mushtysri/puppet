define install_jdk ($jdk_version = undef, $jdk_folder = undef, $jdk_path = undef, $manage_symlink = true) {
  exec { "download_$jdk_version":
    cwd     => "/usr/local/",
    command => "wget --no-cookies --no-check-certificate --header 'Cookie: oraclelicense=accept-securebackup-cookie' 'http://download.oracle.com/otn-pub/java/jdk/$jdk_folder/$jdk_version.tar.gz' --output-document=$jdk_version.tar.gz",
    creates => "/usr/local/$jdk_version.tar.gz",
    require => Class["software-libs::wget::install"],
    timeout => 7200,
  }

  exec { "extract_$jdk_version":
    cwd     => "/usr/local/",
    timeout  => 600,
    command => "tar -xvf $jdk_version.tar.gz",
    creates => $jdk_path,
    require => [Class["software-libs::tar::install"], Exec["download_$jdk_version"]],
  }

  if $manage_symlink == true {
    file { "/usr/local/jdk/":
      ensure  => "link",
      target  => "$jdk_path",
      owner   => root,
      group   => root,
      mode    => "755",
      require => Exec["extract_$jdk_version"],
    }
  }
}

class software-libs::jdk::install ($additional_jdk7 = false) {
  install_jdk { "installing_jdk_8":
    jdk_version => "jdk-8u45-linux-x64",
    jdk_folder  => "8u45-b14",
    jdk_path    => "/usr/local/jdk1.8.0_45"
  }

  if $additional_jdk7 == true {
    install_jdk { "installing_jdk_7":
      jdk_version    => "jdk-7u71-linux-x64",
      jdk_folder     => "7u71-b14",
      jdk_path       => "/usr/local/jdk1.7.0_71",
      manage_symlink => false
    }
  }
}
