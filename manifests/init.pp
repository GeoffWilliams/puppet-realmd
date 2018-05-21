# Realmd
#
# Support for Relmd+SSSD on RHEL 7.
#
# @example joining a domain
#   class { "realmd":
#     domain      => "mydomain",
#     ad_username => "myuser",
#     ad_password => "topsecret",
#     ou          => ['linux', 'servers'],
#     groups      => ['admins', 'superadmins']
#   }
#
# @param packages List of packages to install to enable support (from in-module data)
# @param domain Domain to join
# @param ad_password AD password to use for joining
# @param ou Array of OUs to use for joining eg `foo,bar,baz` (OU= will be added for you)
# @param services List of services to enable for SSD/Realmd
# @param groups List of groups to add to `simple_allow_groups` (will be flattened for you)
class realmd(
    Array[String] $packages,
    String $domain,
    String $ad_username,
    String $ad_password,
    Array[String] $ou,
    Array[String] $services,
    Array[String] $groups = []
) {

  # flatten the array of $ou
  $_ou = join($ou.map |$o| {
    "OU=${o}"
  }, ",")


  package { $packages:
    ensure => present,
  }

  -> exec { "sssd SSH keypair":
    command => "ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key",
    path    => ['/bin', '/usr/bin'],
    creates => '/etc/ssh/ssh_host_dsa_key',
  }

  -> exec { "join realm":
    command => "/bin/echo ${ad_password} | realm join ${domain} -U ${ad_username} --computer-ou=${_ou}",
    path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    creates => "/etc/krb5.keytab",
  }

  -> file { '/etc/sssd/sssd.conf':
    ensure  => present,
    content => epp('realmd/sssd.conf.epp', {domain => $domain, groups => $groups}),
    owner   => "root",
    group   => "root",
    mode    => '0600',
    notify  => Service[$services],
  }

  -> service { $services:
    ensure => running,
    enable => true,
  }

}

