class Config{
    #constructor
    #must define class variables first
    [String]$FileName

    hidden [String[]]$RawFileContent
    
    Config(){

    }

    Config([String]$FileName){
        $ErrorActionPreference = "Stop"
        $this.FileName = $FileName
        #if it exists get the content, if not ignore
        if(Test-Path $this.FileName){
            $this.RawFileContent = Get-Content -Path $this.FileName
        }
        else{
            throw -join($this.FileName, " Either does not exist or is not accessible")
        }
    }
    
    #Overload this in specific classes
    ParseConfigFile(){
    
    }

    #Overload this in specific classes
    WriteConfigFile([Boolean]$NoClobber){
        
    }

}