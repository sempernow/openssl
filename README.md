# OpenSSL

## [`make.openssl.sh`](make.openssl.sh)

Verify certificates

```bash
☩ openssl verify -CAfile "$root_crt" "$site_crt"
/s/DEV/go/uqrate/v4/assets/keys/tls/openssl/swarm.foo_ecc/site.crt: OK
```

Verify remote site

```bash
☩ time openssl s_client -quiet -connect uqrate.org:443 -brief
CONNECTION ESTABLISHED
Protocol version: TLSv1.3
Ciphersuite: TLS_AES_128_GCM_SHA256
Peer certificate: CN = uqrate.org
Hash used: SHA256
Signature type: RSA-PSS
Verification: OK
Server Temp Key: X25519, 253 bits

real    0m30.071s
user    0m0.016s
sys     0m0.016s
```


## Broswers : Untrusted Certificates 

### @ Firefox 

#### `about:config` > `security.enterprise_roots.enabled true`

