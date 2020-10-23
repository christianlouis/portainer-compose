Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature

$pwd = Read-Host "Enter the SafeModeAdminPassword" -AsSecureString
$usernumber = Read-Host "Enter your user number, e.g. for user01 enter 01"

$pwd = Read-Host "Enter the SafeModeAdminPassword" -AsSecureString
Install-ADDSForest `
-DomainName ad.user$usernumber.esxi.akamaipartnertraining.com -DomainNetBiosName ADUSER$usernumber `
-DomainMode WinThreshold -ForestMode WinThreshold `
-SkipPreChecks `
-InstallDns:$true `
-SafeModeAdministratorPassword $pwd `
-Force

ipconfig /registerdns
