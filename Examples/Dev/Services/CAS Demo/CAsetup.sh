cat > root.conf <<- EOM
[ req ]
distinguished_name = req_distinguished_name
x509_extensions    = v3_ca
prompt             = no
[ req_distinguished_name ]
commonName = gcp.bearpug.io
[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints=critical, CA:true
EOM
openssl req -x509 -new -nodes -config root.conf -keyout rootCA.key \
  -days 3000 -out rootCA.crt -batch
cat > extensions.conf <<- EOM
basicConstraints=critical,CA:TRUE,pathlen:0
keyUsage=critical,keyCertSign,cRLSign
extendedKeyUsage=critical,serverAuth,clientAuth,codeSigning
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOMå