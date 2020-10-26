#   Usage: script <Gatewaynumber> <Host IP> <IPv6 Network ending in ::>





nextip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

broadcast(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 7 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}



previousip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX - 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}




NETWORK=$(previousip $2)
HOST=$2
BROADCAST=$(broadcast $NETWORK)
BEGINRANGE=$(nextip $HOST)
ENDRANGE=$(previousip $BROADCAST)

echo Configuring Host: gateway$1

hostnamectl set-hostname gateway$1

echo Host: $HOST
echo Network: $NETWORK/29
echo Broadcast: $BROADCAST
echo Begin DHCP Range: $BEGINRANGE
echo End DHCP RAnge: $ENDRANGE
echo IPv6 Network: $3


cp /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml.orig
cp /etc/dhcp/dhcpd.conf /tmp/dhcpd.conf.orig
cp /etc/radvd.conf /tmp/radvid.conf.orig
cp /etc/bind/named.conf.options /tmp/named.conf.options.orig


sed -i "s/2a01:4f9:4b:15c8::/$3/g" /etc/netplan/01-netcfg.yaml
sed -i "s/2a01:4f9:4b:15c8::/$3/g" /etc/radvd.conf
sed -i "s/2a01:4f9:4b:11c6::/$3/g" /etc/radvd.conf
sed -i "s/135.181.124.25/$HOST/g" /etc/netplan/01-netcfg.yaml
sed -i "s/135.181.124.25/$HOST/g" /etc/bind/named.conf.options
sed -i "s/135.181.124.25/$HOST/g" /etc/dhcp/dhcpd.conf
sed -i "s/135.181.124.24/$NETWORK/g" /etc/dhcp/dhcpd.conf
sed -i "s/135.181.124.26/$BEGINRANGE/g" /etc/dhcp/dhcpd.conf
sed -i "s/135.181.124.30/$ENDRANGE/g" /etc/dhcp/dhcpd.conf
sed -i "s/135.181.124.31/$BROADCAST/g" /etc/dhcp/dhcpd.conf
sed -i "s/router02.dmz.akamaipartnertraining.com/user$1.esxi.akamaipartnertraining.com/g" /etc/dhcp/dhcpd.conf


sudo /etc/init.d/isc-dhcp-server restart
sudo service bind9 restart
sudo /etc/init.d/radvd restart

netplan apply
