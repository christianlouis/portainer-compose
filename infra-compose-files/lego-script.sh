for i in {01..48}; do echo Requesting cert for $i; \ 
lego -d user$i.adfs.akamaipartnertraining.com -d certauth.user$i.adfs.akamaipartnertraining.com --dns route53 --email chlouis@akamai.com -k rsa4096 run; \
openssl pkcs12 -export -out /var/www/html/certs/user$i.adfs.akamaipartnertraining.com.pfx -inkey /root/.lego/certificates/user$i.adfs.akamaipartnertraining.com.key -in /root/.lego/certificates/user$i.adfs.akamaipartnertraining.com.crt -certfile /root/.lego/certificates/user$i.adfs.akamaipartnertraining.com.issuer.crt -passout pass:; \
chmod 644 /var/www/html/certs/user$i.adfs.akamaipartnertraining.com.pfx; \
done
