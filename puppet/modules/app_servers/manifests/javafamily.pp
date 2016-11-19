class javafamily { 
 class { 'java': }
notify{"The machine architecture is $::architecture $::operatingsystem":}
  if $osfamily == 'redhat' {
    notify{"the os is redhat":}
  }
  elsif $osfamily == 'debian' {
    notify{"the os is debian":}
  }
  else {
    notify{"unknown os":}
  }

  if $osfamily == 'redhat' {
    class { 'java': package => 'java-1.8.0-openjdk-devel', }
  }
   elsif $osfamily == 'debian' {
class { 'jdk_oracle': version => 8, }
  } else {
    fail('Invalid OS')
  }
}
