# Realmd
# Fixme fails to start sssd if ANY file is present at /etc/sssd/sssd.conf!
# @param packages List of packages to install to enable support
class realmd(
    Array[String] $packages,
    String $domain,
    String $ad_username,
    String $ad_password,
    Array[String] $ou,
    Array[String] $services,
    Array[String] $groups = []
) {

  package { $packages:
    ensure => present,
  }


  # FIXME raw groups like this?
  # content has to be string interpolated or funky casting gives an error about integer conversion, has to broken
  # into variables to prevent lint and syntax errors (although it works... go figure)
  $groups_flattened = $groups.join(" ")
  $template_contents = epp('realmd/sssd.conf.epp', {domain => $domain})
  file { '/etc/sssd/sssd.conf':
    ensure  => present,
    content => "${groups_flattened}\n${template_contents}",
    owner   => "root",
    group   => "root",
    mode    => '0600',
    notify  => Service[$services],
  }

  exec { "sssd SSH keypair":
    command => "ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key",
    path    => ['/bin', '/usr/bin'],
    creates => '/etc/ssh/ssh_host_dsa_key',
  }

  # flatten the array of $ou
  $_ou = join($ou.map |$o| {
    "OU=${o}"
  }, ",")

  exec { "join realm":
    command => "/bin/echo ${ad_password} | realm join ${domain} -U ${ad_username} --computer-ou=${_ou}",
    path    => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
    creates => "/etc/krb5.keytab",
    require => Package[$packages],
  }

  service { $services:
    ensure => running,
    enable => true,
  }


  # FIXME these are already in place - needed? tweaks?
  # file { '/etc/pam.d/password-auth':
  #   ensure => file,
  #   owner => 'root',
  #   group => 'root',
  #   mode => '0644',
  #   source => $password_auth_source,
  # }
  #
  # file { '/etc/pam.d/system-auth':
  #   ensure => file,
  #   owner => 'root',
  #   group => 'root',
  #   mode => '0644',
  #   source => $system_auth_source,
  # }


  # SMB doesnt seem used?
  #    class { '::smb':
  #      realm           => $domain,
  #      workgroup       => $workgroup,
  #      passwordserver  => $pwserver,
  #      linuxou         => $linixou,
  #      adusername      => $username,
  #      adpassword      => $password,
  #    }->


  # FIXME whats this?
  # class { '::sssd_realmd':
  #   sssd_domain                    => $domain,
  #   sssd_ldap_user_search_base     => $searchbase,
  #   sssd_ldap_group_search_base    => $searchbase,
  #   allowed_groups                 => [ $groups ],
  # }

}

