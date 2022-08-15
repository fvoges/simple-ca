# Simple CA

> :warning:  Do not use this in production. This is intended for testing only.

This repo contains a couple of scripts to generate a CA, server certificates, client TLS certificates.

The certificates generated can then be used with [HashiCorp Vault](https://www.vaultproject.io/) (hence the names used).

You can customize the names used by modifying the `gen_*.sh` scripts.

- `gen_certs.sh` - generates the CA and server certificates
- `gen_client_cert.sh` - generates client certificates
- `nuke_certs.sh` - deletes all the generated data
- `.vars` - contains the variables with the paths used by the scripts
