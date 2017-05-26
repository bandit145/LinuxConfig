using module ./Configs/SSHDConf.psm1
$test = [SSHDConf]::new()
$test.Compression
#$test.ParseConfigFile()
#$test.WriteConfigFile($false)