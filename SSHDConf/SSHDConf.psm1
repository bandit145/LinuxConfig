using module ./Config

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

    [int[]]$Protocol = @(1,2)
    [String[]]$HostKey
    [ValidateSet("yes","no")]$UsePrivilegeSeparation = "yes"
    [Int]$KeyRegenerationInterval = 3600
    [Int]$ServerKeyBits
    [ValidateSet("DAEMON","USER","AUTH","AUTHPRIV","LOCAL0","LOCAL1","LOCAL2","LOCAL3","LOCAL4","LOCAL5","LOCAL6","LOCAL7")]$SyslogFacility = "AUTH"
    [ValidateSet("QUIET","FATAL","ERROR","INFO","VERBOSE","DEBUG","DEBUG1","DEBUG2","DEBUG3")]$LogLevel = "INFO"
    [int]$LoginGraceTime = 120
    #proto 1 only
    [ValidateSet("yes","no")]$RSAAuthentication = "yes"
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
    [ValidateSet("yes","no","without-password","forced-commands-only")]$PermitRootLogin = "yes"
    [ValidateSet("yes","point-to-point","ethernet","no")]$PermitTunnel = "no"
    [ValidateSet("yes","no")]$PermitUserEnvironment = "no"
    [String]$PidFile

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
    [Match[]]$Matches
    [ValidateSet("yes","no")]$X11Forwarding = "no"
    [int]$X11DisplayOffset = 10
    [ValidateSet("yes","no")]$X11UseLocalHost = "yes"
    [String]$PrintMotd
    [ValidateSet("yes","no")]$PrintLastLog = "yes"
    [ValidateSet("yes","no")]$TCPKeepAlive = "no"
    [ValidateSet("yes","no")]$UseLogin = "no"
    [String]$MaxStartups
    [String]$Banner
    [String[]]$AcceptEnv
    [String[]]$SendEnv
    [String]$Subsystem
    [ValidateSet("yes","no")]$UseDNS = "yes"
    #technically the default is "no" but I have never seen a default install run it that way
    [ValidateSet("yes","no")]$UsePam = "yes"
    [String[]]$RequiredAuthentications1
    [String[]]$RequiredAuthentications2
    [ValidateSet("yes","no")]$ShowPatchLevel = "no"
    [ValidateSet("yes","no")]$StrictModes = "yes"

    SSHDConf() : Base(){
        
    }

    SSHDConf([String]$FileName) : Base($FileName){
        
    }


    ParseConfigFile(){
        $ErrorActionPreference = "Stop"
        foreach($line in $this.RawFileContent){
            $key, $value = $line.Split()
            if(($key -eq "HostKey") -or ($key -eq "AcceptEnv")){
                $this.$key += $value
            }
            #not currently working
            #OH MY GOD ITS NESTED IM GOING TO DIE
            elseif($key -eq "Match"){
                $match = [Match]::new()
                $match.Match = $line.Split()
                $curline = [array]::IndexOf($this.RawFileContent,$line)
                for(i=$curline+1; i -le $line.Length; i++){
                    $tab, $data  = $line[$curline].split()
                    if($tab -eq "`t"){
                        $match.$data[0] = $data[1]
                    }
                    else{
                        break
                    }
                }
            }
            elseif(($key -eq "Ciphers") -or ($key -eq "MACs")){
                #ciphers is a comma delimted list
                $key, $value = $line.Split()
                $value = $value.Split(",")
                foreach($data in $value){
                    $this.$key += $data
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
        [System.Collections.ArrayList] $members = (Get-Member -InputObject $this -MemberType Properties | Where-Object {$_.Name -ne "FileName"}).Name
        #Denyusers, AllowUsers,DenyGroups, AllowGroups, need to be in this order
        #Then remove from arraylist so it doesn't get written twice
        foreach($key in @("DenyUsers","AllowUsers","DenyGroups","AllowGroups")){
            $outfile += $this.write_groups($this.$key, $key)
            $members.Remove($key)
        }
        foreach($key in $members){
            #if nothing set then set as comment
            if ($this.$key.Length -lt 1){
                $outfile += "#$key`n"
            }
            #if hostkey then set as one value with mutiple keys of same name
            elseif(($key -eq "HostKey") -or ($key -eq "AcceptEnv")){
                foreach($value in $this.$key){
                    $outfile += -join($key," $value`n")
                }
            }
            #if array of strings unfurl onto one line
            else{
                if($this.$key -is "System.Array"){
                    $outfile += $this.write_groups($this.$key, $key)
                }
                #Handle as standard key value
                else{
                    $outfile += -join($key," ", $this.$key, "`n")
                }
            }
            #Write out matches at end for consistency 
            if($this.Matches.Length -gt 0){

            }
        
        }
        if($NoClobber){
                if(Test-Path -Path $this.FileName){
                    Copy-Item -Path $this.FileName -Destination (-join($this.FileName,".bak"))
                }
            }
            Out-File -InputObject $outfile -FilePath $this.FileName
    }

    #Groups delmited by space
   hidden [String] write_groups([System.Array]$value, [String]$key){
        if ($key.Length -ge 1){
            $buffer = ""
            foreach($entry in $value){
                if(($key -eq "Chiphers") -or ($key -eq "MACs") -or ($key -eq "Protocol") -or ($key -eq "RequiredAuthentications1") -or ($key -eq "RequiredAuthentications2")){
                    #Oh god forgive me
                    if($value.IndexOf($entry) -eq ($value.Length - 1)){
                        $buffer += -join($entry)  
                    }
                    else{
                        $buffer += -join($entry,",")
                    }
                }
                else{
                    $buffer += -join($entry," ")
                }
            }
            return -join($key, " ", $buffer, "`n")
        }
        else{
            return "#$key`n"
        }
    }
}




class Match{
    #Only a subset of keywords are allowed in a match to overide global config
    [String[]]$Match
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
    [ValidateSet("yes","no")]$PermitRootLogin = "yes"
    [String[]]$RequiredAuthentications1
    [String[]]$RequiredAuthentications2
    [ValidateSet("yes","no")]$RHostsRSAAuthentication = "no"
    [ValidateSet("yes","no")]$RSAAuthentication = "yes"
    [int]$X11DisplayOffset = 10
    [ValidateSet("yes","no")]$X11Forwarding = "no"
    [ValidateSet("yes","no")]$X11UseLocalHost = "yes"
}
