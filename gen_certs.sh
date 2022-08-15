#!/bin/bash

function cleanup {
  test -f csr.conf && rm -f csr.conf
}

trap cleanup EXIT

. .vars

CA_NAME="My private test CA"
CA_DAYS="1825"

HOST="vault"
DOMAIN="local"
FQDN="${HOST}.${DOMAIN}"
IP="127.0.0.1"
ALT_NAMES="DNS = $HOST
DNS.1 = $FQDN
DNS.2 = vault01
DNS.3 = vault01.local
DNS.4 = vault02
DNS.5 = vault02.local
DNS.6 = vault03
DNS.7 = vault03.local
DNS.8 = localhost
IP = 127.0.0.1
"
DAYS="10000"

CRT_PREFIX="${CRT_DIR}/${FQDN}"

mkdir -p $CA_DIR $CRT_DIR

cat << EOF > $CA_PREFIX.conf
[ req ]
prompt                 = no

# Options for the req tool (man req).
default_bits           = 4096
distinguished_name     = req_distinguished_name
string_mask            = utf8only

# SHA-1 is deprecated, please use SHA-2 or greater instead.
default_md             = sha384

# Extension to add when the -x509 option is used.
x509_extensions        = v3_ca

[ req_distinguished_name ]
commonName             = $CA_NAME

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign

EOF


echo CA Key
test -f $CA_PREFIX.key || openssl genrsa -out $CA_PREFIX.key 2048
echo CA Cert
test -f $CA_PREFIX.crt || openssl req -x509 -new -nodes -key $CA_PREFIX.key -days $CA_DAYS -out $CA_PREFIX.crt -sha256 -config $CA_PREFIX.conf -extensions v3_ca
echo Server Key
test -f $CRT_PREFIX.key || openssl genrsa -out $CRT_PREFIX.key 2048

cat > csr.conf <<-EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = $FQDN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
$ALT_NAMES
EOF

echo Server CSR
openssl req -new -key $CRT_PREFIX.key -out $CRT_PREFIX.csr -config csr.conf

echo Server cert
openssl x509 -req -in $CRT_PREFIX.csr -CA $CA_PREFIX.crt -CAkey $CA_PREFIX.key -CAcreateserial -out $CRT_PREFIX.crt -days $DAYS -extfile csr.conf -extensions req_ext -sha256
