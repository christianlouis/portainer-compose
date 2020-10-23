$usernumber = Read-Host "Enter your user number, e.g. for user01 enter 01"

Import-Module ADFS

Install-AdfsFarm `
-CertificateThumbprint:"A47928498C4DF9ABFC92FFC91EEC852CA9FB1525" `
-FederationServiceDisplayName:"User$usernumber Akamai Partner Training" `
-FederationServiceName:"user$usernumber.adfs.akamaipartnertraining.com" `
-GroupServiceAccountIdentifier:"ADUSER$usernumber\Serviceuser_ADFS`$"
