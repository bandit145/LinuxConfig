using module ./Configs/SSHDConf.psm1

#Parses config from a file
Function Get-Config{
    <#
        .DESCRIPTION
        Gets a Linux configuration file object
        .SYNOPSIS
        Get-Config will parse a Linux confguration file into an object (supported!) 
        with the  -FileLocation Parameter
        .EXAMPLE
        Parsed sshd_config file: Get-Config -ConfigType SSHDConf -FileLocation /etc/ssh/sshd_config 
        .LINK
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,Position=0)]
        [ValidateSet("SSHDConf")]$ConfigType,
        [parameter(Mandatory=$true,Position=1)]
        [String]$FileLocation
    )
    $ErrorActionPreference = "Stop"
    $configobj = New-Object -TypeName $ConfigType -ArgumentList $FileLocation
    $configobj.ParseConfigFile()

    return $configobj
}

#Gets Default version of a config
Function New-Config{
    <#
        .DESCRIPTION
        Gets a default Linux configuration file object
        .SYNOPSIS
        New-Config gets a default config of the specified Linux config file type
        .EXAMPLE
        New sshd_config file: Get-Config -ConfigType SSHDConf
        .LINK
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,Position=0)]
        [ValidateSet("SSHDConf")]$ConfigType
    )
    $ErrorActionPreference = "Stop"
    $configobj = New-Object -TypeName $ConfigType
    return $configobj
}

Function Set-Config{
    <#
        .DESCRIPTION
        Writes Config object out to a file
        .SYNOPSIS
        Set-Config writes out the provided Config object to a file
        Using -NoClobber sets the pre-existing file (if it exits) to "Filename".bak 
        .EXAMPLE
        1: Set-Config -InputObject $sshd_config
        2: ForEach-Object -InputObject $array_of_sshd_configs | Set-Config
        3: Set-Config -InputObject $sshd_config -NoClobber
        .LINK
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$true,position=0)]
        [Config]$InputObject,
        [parameter()]
        [Switch]$NoClobber
    )
    $ErrorActionPreference = "Stop"
    Process{
        $InputObject.WriteConfigFile($NoClobber)
    }
}