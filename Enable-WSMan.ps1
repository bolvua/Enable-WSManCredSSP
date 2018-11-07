$YourHostName = "Hostname"
$YourDomainName = "domain.local"
# Enable WSMandCredSSP Role Client with delegation
if(!(Test-WsMan -Authentication Credssp -ComputerName "$YourHostName.$YourDomainName" -Credential $Credential -ErrorAction SilentlyContinue))
{
## Condition if Enable-WSManCredSSP failed (can happen) will do it directly on registry keys
    if(!(Enable-WSManCredSSP -Role "Client" -DelegateComputer "*.$YourDomainName" -Force -ErrorAction SilentlyContinue)){
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
        $i = 1
        $key | ForEach-Object {
            New-ItemProperty -Path $keypath -Name $i -Value $_ -PropertyType String -Force
            New-ItemProperty -Path $keypath2 -Name $i -Value $_ -PropertyType String -Force
            $i++
        }
        #wait for write registry keys
        Start-Sleep -Seconds 2
        #Enable WSManCredSSP second try
        Enable-WSManCredSSP -Role "Client" -DelegateComputer "*.$YourDomainName" -Force -ErrorAction SilentlyContinue
    }
}
# ---------------------------------------------
