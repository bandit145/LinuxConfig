using module ./Configs/SSHDConf.psm1


Function Get-Config{
    <#
        .DESCRIPTION
        Gets a Linux configuration file object
        .SYNOPSIS
        Get-Config will either get a default Linux configfile object or it will parse one into and object if supplied
        with the  -FileLocation Parameter
        .EXAMPLE
        Default sshd_config: Get-Config -ConfigType SSHDConf
        Parsed sshd_config file: Get-Config -ConfigType SSHDConf -FileLocation /etc/ssh/sshd_config 
        .LINK
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,Position=0)]
        [ValidateSet("SSHDConf")]$ConfigType,
        [parameter(Position=1)]
        [String]$FileLocation
    )
    $ErrorActionPreference = "Stop"

    if($FileLocation){
        $configobj = New-Object -TypeName $ConfigType -ArgumentList $FileLocation
        $configobj.ParseConfigFile()
    }
    else{
        $configobj = New-Object -TypeName $ConfigType
    }
    return $configobj
}