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

endrangeip(){
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 5 ))`)
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
ENDRANGE=$(endrangeip $NETWORK)

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


sudo apt-get install -y -q docker.io less vim lsof strace nmap 


mkdir /iredmail         # Create a new directory or use any directory
                        # you prefer. `/iredmail/` is just an example
cd /iredmail
touch iredmail-docker.conf

echo HOSTNAME=mail.user$i-lab.com >> iredmail-docker.conf
echo FIRST_MAIL_DOMAIN=user$i-lab.com >> iredmail-docker.conf
echo FIRST_MAIL_DOMAIN_ADMIN_PASSWORD=4XVjGX45rpZe56cwNNEj >> iredmail-docker.conf
echo MLMMJADMIN_API_TOKEN=$(openssl rand -base64 32) >> iredmail-docker.conf
echo ROUNDCUBE_DES_KEY=$(openssl rand -base64 24) >> iredmail-docker.conf

cd /iredmail
mkdir -p data/{backup,clamav,custom,imapsieve_copy,mailboxes,mlmmj,mlmmj-archive,mysql,sa_rules,ssl,postfix_queue}

docker run --rm  --name iredmail  --env-file iredmail-docker.conf  --hostname mail.user$i-lab.com     -p 80:80     -p 443:443     -p 110:110     -p 995:995     -p 143:143     -p 993:993     -p 25:25     -p 465:465     -p 587:587     -v /iredmail/data/backup:/var/vmail/backup     -v /iredmail/data/mailboxes:/var/vmail/vmail1     -v /iredmail/data/mlmmj:/var/vmail/mlmmj     -v /iredmail/data/mlmmj-archive:/var/vmail/mlmmj-archive     -v /iredmail/data/imapsieve_copy:/var/vmail/imapsieve_copy     -v /iredmail/data/custom:/opt/iredmail/custom     -v /iredmail/data/ssl:/opt/iredmail/ssl     -v /iredmail/data/mysql:/var/lib/mysql     -v /iredmail/data/clamav:/var/lib/clamav     -v /iredmail/data/sa_rules:/var/lib/spamassassin     -v /iredmail/data/postfix_queue:/var/spool/postfix  -d  iredmail/mariadb:stable
