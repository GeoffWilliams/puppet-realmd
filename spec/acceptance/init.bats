@test "group admins added to config file" {
    grep admins /etc/sssd/sssd.conf
}

@test "group superadmins added to config file" {
    grep superadmins /etc/sssd/sssd.conf
}
