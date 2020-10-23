# DHCP deaktivieren:
Set-NetIPInterface -InterfaceAlias "Ethernet0" -AddressFamily IPv4 -DHCP Disabled -PassThru
 
# IPs ändern:
New-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet0" -IPAddress 192.168.1.5 -PrefixLength 24 -DefaultGateway 192.168.1.1
 
# DNS ändern:
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.5
 
# IPv6 deaktivieren:
Disable-NetAdapterBinding -Name Ethernet -ComponentID ms_tcpip6
 
# Server umbenennen:
Rename-Computer -NewName DC01 -Restart -Force
