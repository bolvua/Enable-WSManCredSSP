## Enable-WSManCredSSP

Enable-WSManCredSSP -role Client -DelegationComputer is not working properly every time. So I created this script as workaround.
Sometimes you can have problem with command **Enable-WSManCredSSP -Role client -DelegateComputer "my host"**
That is because command has no access for registry editing even when you are running PowerShell as administrator.

### Requires
  1. Enable WinRM on both sites - (winrm quickconfig)
  2. Chceck WinRM configs (winrm get winrm/config/client - winrm get winrm/config/service)
  2. Set TrustedHosts (Set-Item -Path "WSMan:\localhost\Client\TrustedHosts" -Value '*' -Force)

### Just Set-up your DomainName and HostName of your target computer and your domain credentials

### In couple days I will create script also for Disable-WSManCredSSP
