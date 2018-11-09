#Here just define your variable
$YourHostName = "Hostname"
$YourDomainName = "domain.local"

# Test Connection
if(!(Test-WsMan -Authentication Credssp -ComputerName "$YourHostName.$YourDomainName" -Credential $Credential -ErrorAction SilentlyContinue))
{
    # Try to Enable-WSManCredSSP - If failed (can happen) will do it directly on registry keys
    if(!(Enable-WSManCredSSP -Role "Client" -DelegateComputer "*.$YourDomainName" -Force -ErrorAction SilentlyContinue)){
        #in object $key can be added more than one record. Example @("wsman/*.$YourDomainName","wsman/*.$secondDomainName",..)
        $key = @("wsman/*.$YourDomainName")
        $mainpath = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
        if (!(Test-Path $mainpath)) {
            mkdir $mainpath
        }
        $AllowFreshCredentials = Get-ItemProperty -Path $mainpath  | where-Object {$_.AllowFreshCredentials -eq "1"}
        $AllowFreshCredentialsNTML = Get-ItemProperty -Path $mainpath  | where-Object {$_.AllowFreshCredentialsWhenNTLMOnly -eq "1"}
        if (!$AllowFreshCredentials){
            New-ItemProperty -Path $mainpath -Name AllowFreshCredentials -Value 1 -PropertyType Dword -Force
        }
        if (!$AllowFreshCredentialsNTML){
            New-ItemProperty -Path $mainpath -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force
        }  
        $keypath = Join-Path $mainpath 'AllowFreshCredentials'
        $keypath2 = Join-Path $mainpath 'AllowFreshCredentialsWhenNTLMOnly'
        if (!(Test-Path $keypath)) {
            mkdir $keypath
        }
        if (!(Test-Path $keypath2)) {
            mkdir $keypath2
        }
        #create new Items for every object in keys
        $i = 1
        $key | ForEach-Object {
            New-ItemProperty -Path $keypath -Name $i -Value $_ -PropertyType String -Force
            New-ItemProperty -Path $keypath2 -Name $i -Value $_ -PropertyType String -Force
            $i++
        }
        #wait for write registry keys - not necessary
        Start-Sleep -Seconds 1
        #Enable WSManCredSSP second try
        Enable-WSManCredSSP -Role "Client" -DelegateComputer "*.$YourDomainName" -Force -ErrorAction SilentlyContinue
    }
}
# ---------------------------------------------
