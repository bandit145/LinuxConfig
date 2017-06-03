using module ./SSHDConf
#yeah, yeah relative paths
<#
    Pester Test for SSHDConf Class -Philip Bove
#>
Describe "Test SSHDConf out"{
    It "Get default config"{
        $SSHDConf = [SSHDConf]::new()
        $SSHDConf.Port | Should Be(22)
    }
    #Verify Reading from an existing Config
    It "Get Config from file"{
        $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config")
        $SSHDConf.ParseConfigFile()
        $SSHDConf.Port | Should Be(50)
        $SSHDConf.HostKey[0] | Should Be("/etc/ssh/ssh_host_rsa_key")
        $SSHDConf.PermitRootLogin | Should Be("no")
        $SSHDConf.AcceptEnv[0] | Should Be("LANG") 
    }
    #Test Writing out
    It "Create sshd_config file from default config"{
         $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config_new")
         $SSHDConf.Port = 50
         $SSHDConf.AllowUsers = "Doot","wat"
         $SSHDConf.AcceptEnv = "LANG","LOL"
         $SSHDConf.HostKey = "test","test2","test3"
         $SSHDConf.WriteConfigFile($false)
    }
    #Verify generated config works
    It "Read from sshd_config_new"{
        $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config_new")
        $SSHDConf.ParseConfigFile()
        $SSHDConf.Port | Should Be(50)
        $SSHDConf.AllowUsers[0] | Should Be("Doot")
        $SSHDConf.AllowUsers[1] | Should Be ("wat")
        $SSHDConf.AcceptEnv[0] | Should Be("LANG")
        $SSHDConf.AcceptEnv[1] | Should Be ("LOL")
        $SSHDConf.HostKey[0] | Should Be("test")
        $SSHDConf.HostKey[1] | Should Be("test2")
        $SSHDConf.HostKey[2] | Should Be("test3")
    }

    #Test Writing out with -NoClobber
    It "Overwrite SSHD config with noclobber"{
         $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config_new")
         $SSHDConf.Port = 60
         $SSHDConf.AllowUsers = "Doot","toot"
         $SSHDConf.AcceptEnv = "LANG","LOL"
         $SSHDConf.HostKey = "test","test2","test3"
         $SSHDConf.WriteConfigFile($true)
    }

    #Verify that .bak exists proper
    It "Read from sshd_config_new.bak"{
        $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config_new.bak")
        $SSHDConf.ParseConfigFile()
        $SSHDConf.Port | Should Be(50)
        $SSHDConf.AllowUsers[0] | Should Be("Doot")
        $SSHDConf.AllowUsers[1] | Should Be ("wat")
        $SSHDConf.AcceptEnv[0] | Should Be("LANG")
        $SSHDConf.AcceptEnv[1] | Should Be ("LOL")
        $SSHDConf.HostKey[0] | Should Be("test")
        $SSHDConf.HostKey[1] | Should Be("test2")
        $SSHDConf.HostKey[2] | Should Be("test3")
    }

      It "Read from NEW sshd_config_new"{
        $SSHDConf = [SSHDConf]::new("$PSScriptRoot/sshd_config_new")
        $SSHDConf.ParseConfigFile()
        $SSHDConf.Port | Should Be(60)
        $SSHDConf.AllowUsers[0] | Should Be("Doot")
        $SSHDConf.AllowUsers[1] | Should Be ("toot")
        $SSHDConf.AcceptEnv[0] | Should Be("LANG")
        $SSHDConf.AcceptEnv[1] | Should Be ("LOL")
        $SSHDConf.HostKey[0] | Should Be("test")
        $SSHDConf.HostKey[1] | Should Be("test2")
        $SSHDConf.HostKey[2] | Should Be("test3")
      }
    #Remove-Item -Path "$PSScriptRoot/sshd_config_new","$PSScriptRoot/sshd_config_new.bak"
}