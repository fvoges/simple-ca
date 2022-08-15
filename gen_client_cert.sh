#!/bin/bash

. .vars

function cleanup {
  test -f csr.conf && rm -f csr.conf
}

trap cleanup EXIT

ENV="${1:-uat}"
GRP="${2:-cwc}"
APP="${3:-svc1}"

CN="${ENV}-${GRP}-${APP}"
IP="127.0.0.1"
ALT_NAMES="DNS = ${CN}
DNS.1 = vault01
DNS.2 = vault01.local
DNS.3 = vault02
DNS.4 = vault02.local
DNS.5 = vault03
DNS.6 = vault03.local
DNS.7 = localhost
IP = 127.0.0.1
"
DAYS="10000"

CRT_PREFIX="${CRT_DIR}/${CN}"

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
CN = $CN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
$ALT_NAMES
EOF

echo Client CSR
openssl req -new -key $CRT_PREFIX.key -out $CRT_PREFIX.csr -config csr.conf

echo Client cert
openssl x509 -req -in $CRT_PREFIX.csr -CA $CA_PREFIX.crt -CAkey $CA_PREFIX.key -CAcreateserial -out $CRT_PREFIX.crt -days $DAYS -extfile csr.conf -extensions req_ext -sha256

