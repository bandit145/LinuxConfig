using module ./Configs/Config.psm1


class SSHDConf : Config{
    #Keys in config file
    #Source: man sshd_config
    [int]$Port = 22
    [String]$ListenAddress
    [ValidateSet("any","inet","inet6")]$AddressFamily = "any"
    [ValidateSet("yes","no")]$AllowAgentForwarding = "yes"
    [String[]]$AllowGroups
    [String[]]$AllowUsers
    [ValidateSet("yes","no")]$AllowTCPForwarding = "yes"
    [String]$ChrootDirectory
    [int]$ClientAliveInterval
    [ValidateSet("yes","no","delayed")]$Compression = "delayed"
    [String[]]$Ciphers
    [String[]]$DenyUsers
    [String[]]$DenyGroups
    [String]$ForceCommand
    [ValidateSet("yes","no","clientspecified")]$GatewayPorts

    [String]$Protocol
    [String[]]$HostKey
    [String]$UsePrivilegeSeparation
    [Int]$KeyRegenerationInterval = 3600
    [Int]$ServerKeyBits
    [String]$SyslogFacility
    [ValidateSet("QUIET","FATAL","ERROR","INFO","VERBOSE","DEBUG","DEBUG1","DEBUG2","DEBUG3")]$LogLevel = "INFO"
    [int]$LoginGraceTime = 120
    [String]$StrictModes
    #proto 1 only
    [ValidateSet("yes","no")]$RSAAuthentication = "no"
    [ValidateSet("yes","no")]$PubkeyAuthentication = "yes"
    [String]$AuthorizedKeysFile = "%h/.ssh/authorized_keys"
    [String]$AuthorizedKeysCommand
    [String]$AuthorizedKeysCommandUser
    [ValidateSet("yes","no")]$IgnoreRHosts = "yes"
    [String]$RHostsRSAAuthentication
    [ValidateSet("yes","no")]$HostbasedAuthentication = "no"
    [ValidateSet("yes","no")]$HostBasedUsesNameFromPacketOnly = "no"
    [ValidateSet("yes","no")]$IgnoreUserKnownHosts = "no"
    [String]$PermitEmptyPasswords
    [String]$PermitRootLogin
    [ValidateSet("yes","no")]$ChallengeResponseAuthentication = "yes"
    [String]$PasswordAuthentication
    [ValidateSet("yes","no")]$KerberosAuthentication = "no"
    [ValidateSet("yes","no")]$KerberosGetAFSToken = "no"
    [ValidateSet("yes","no")]$KerberosOrLocalPasswd = "yes"
    [ValidateSet("yes","no")]$KerberosTicketCleanup = "yes"
    [ValidateSet("yes","no")]$GSSAPIAuthentication = "no"
    [ValidateSet("yes","no")]$GSSAPIKeyExchange = "no"
    [ValidateSet("yes","no")]$GSSAPICleanupCredentials = "yes"
    [ValidateSet("yes","no")]$GSSAPIStrictAcceptorCheck = "yes"
    [ValidateSet("yes","no")]$GSSAPIStoreCredentialsOnRekey = "no"
    [String[]]$MACs = @("hmac-md5","hmac-sha1","umac-64@openssh.com","hmac-ripemd160","hmac-sha1-96","hmac-md5-96")
    #ytho
    #can match User, Group, Host, Address
    #@(@{MatchType = "User"; Match })
    [Match[]]$Match
    [String]$X11Forwarding
    [String]$X11DisplayOffset
    [String]$PrintMotd
    [String]$PrintLastLog
    [String]$TCPKeepAlive
    [String]$UseLogin
    [String]$MaxStartups
    [String]$Banner
    [String[]]$AcceptEnv
    [String[]]$SendEnv
    [String]$Subsystem
    [String]$UsePam

    SSHDConf() : Base(){
        
    }

    SSHDConf([String]$FileName) : Base($FileName){
        
    }

    ParseConfigFile(){
        $ErrorActionPreference = "Stop"
        foreach($line in $this.RawFileContent){
            $key, $value = $line.Split()
            if($key -eq "HostKey"){
                $this.HostKey += $value
            }
            elseif(($key -eq "Ciphers") -or ($key -eq "MACs")){
                #ciphers is a comma delimted list
                $key, $value = $line.Split(",")
                foreach($cipher in $value){
                    $this.Chipers += $value
                }
            }
            elseif(!($key -match "^#") -and ($key.Length -gt 0)){
                $this.$key = $value
            }
        }
    }

    WriteConfigFile([Boolean]$NoClobber){
        $ErrorActionPreference = "Stop"
        $outfile = ""
        #Get all property members
        $members =  Get-Member -InputObject $this -MemberType Properties | Where-Object {$_.Name -ne "FileName"}
        foreach($key in $members.Name){
            #if nothing set then set as comment
            if ($this.$key.Length -lt 1){
                $outfile += "#$key`n"
            }
            #if hostkey then set as one value with mutiple keys of same name
            elseif($key -eq "HostKey"){
                foreach($value in $this.$key){
                    $outfile += -join("HostKey"," $value`n")
                }
            }
            #if array of strings unfurl onto one line
            else{
                if($this.$key -is "System.String[]"){
                    $buffer = ""
                    foreach($entry in $this.$key){
                        $buffer += -join($entry," ")

                    }
                    $outfile += -join($key, " ", $buffer, "`n")
                }
                #Handle as standard key value
                else{
                    $outfile += -join($key," ", $this.$key, "`n")
                }
        }
        if($NoClobber){
            Copy-Item -Path $this.FileName -Destination $this.FileName".bak"
        }
        Out-File -InputObject $outfile -FilePath $this.FileName
        }
    }
}

class Match{
    #Only a subset of keywords are allowed in a match to overide global config
    [ValidateSet("Group","User","Host","Address")]$MatchType
    [String]$Match
    [ValidateSet("yes","no")]$AllowAgentForwarding
    [ValidateSet("yes","no")]$AllowTCPForwarding
    [String]$Banner
    [String]$ChrootDirectory
    [String]$ForceCommand
    [ValidateSet("yes","no","clientspecified")]$GatewayPorts
    [ValidateSet("yes","no")]$GSSAPIAuthentication = "no"
    [ValidateSet("yes","no")]$HostbasedAuthentication = "no"
    [ValidateSet("yes","no")]$KbdInteractiveAuthentication = "no"
    [ValidateSet("yes","no")]$KerberosAuthentication = "no"
    [ValidateSet("yes","no")]$KerberosUseKuserok = "yes"
    [int]$MaxAuthTries = 6
    [int]$MaxSessions = 10
    [ValidateSet("yes","no")]$PubkeyAuthentication = "yes"
    [String]$AuthorizedKeysCommand
    [String]$AuthorizedKeysCommandUser
    [ValidateSet("yes","no")]$PasswordAuthentication = "yes"
    [ValidateSet("yes","no")]$PermitEmptyPasswords = "no"
    [String]$PermitOpen
    [ValidateSet("yes","no","without-password","forced-commands-only")]$PermitRootLogin = "yes"
    [String[]]$RequiredAuthentications1
    [String[]]$RequiredAuthentications2
    [ValidateSet("yes","no")]$RHostsRSAAuthentication = "no"
    [ValidateSet("yes","no")]$RSAAuthentication = "no"
    [int]$X11DisplayOffset = 10
    [ValidateSet("yes","no")]$X11Forwarding = "no"
    [ValidateSet("yes","no")]$X11UseLocalHost = "yes"


    Match(){

    }
}
