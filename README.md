## Enable-WSManCredSSP

Enable-WSManCredSSP -role Client -DelegationComputer is not working properly every time. So I created this script as workaround
Sometimes you can have problem with command Enable-WSManCredSSP -Role client -DelegateComputer "my host"
That is because command has no access for registry editing even when you are running PowerShell as administrator.

### Just Set-up your DomainName and HostName of your local computer

### In couple ways I will create script also for Disable-WSManCredSSP
