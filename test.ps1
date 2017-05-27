using module ./SSHDConf
$test = [SSHDConf]::new("Tests/SSHDConf/sshd_config_new")

$test.ParseConfigFile()
$test.Port = "90"
$test.WriteConfigFile($true)

#$test.WriteConfigFile($false)