#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Makefile : TLS certification recipes
# 
# openssl : Generate Self-signed Site Certificate (RSA|ECC)
# https://docs.docker.com/engine/swarm/configs
# -----------------------------------------------------------------------------

[[ $DOMAIN ]] || { echo "REQUIREd vars UNSET"; exit 0; }

# Params
length='4096' # @ RSA
c=${TLS_C:-US};st=${TLS_ST:-NY};l=${TLS_L:-Gotham};o=${TLS_O:-Foobar Inc}

cn=${TLS_CN:-swarm.foo}
ip=${TLS_IP:-192.168.1.26}

# Root (self signed) certificate  https://en.wikipedia.org/wiki/Root_certificate
root_key='root-ca.key'         # SECRET key
root_crt='root-ca.crt'         # Root Certificate
root_csr='root-ca.csr'         # Root-cert Signing Request (CSR)
root_cnf='root-ca.cnf'         # Config

site_key='site.key'            # SECRET key; server param
site_crt='site.crt'            # Site Certificate; server param
site_csr='site.csr'            # Certificate Signing Request (CSR)
site_cnf='site.cnf'            # Config

fullchain='site.fullchain.crt' # site_crt + root_crt

# site_csr and site_cnf files are not needed by Nginx service;
# needed to generate a new site certificate.

cert(){ #
	[[ -d ${PATH_OUT} ]] || { 
		echo "DOMAIN directory NOT EXIST"
		exit 0
	}

	# Generate root key 
	#openssl genrsa -out "$root_key" $length                                         # RSA 
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$root_key"  # ECC

	# Generate CSR (Cert Signing Request) 
	openssl req \
		-new -key "$root_key" \
		-out "$root_csr" -sha256 \
		-subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn"

	# Configure root CA : inherit trustworthiness: CA:TRUE
	cat <<-EOR > $root_cnf
	[root_ca]
	basicConstraints = critical,CA:TRUE,pathlen:1
	keyUsage = critical, nonRepudiation, cRLSign, keyCertSign
	subjectKeyIdentifier=hash
	EOR

	# Sign the certificate
	openssl x509 -req -days 3650 -in "$root_csr" \
		-signkey "$root_key" -sha256 -out "$root_crt" \
		-extfile "$root_cnf" -extensions \
		root_ca

	# Generate site key
	##openssl genrsa -out "$site_key" $length                                       # RSA
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$site_key" # ECC

	# Configure site CA
	cat <<-EOR > $site_cnf
	[req]
	distinguished_name = req_distinguished_name
	prompt = no
	[req_distinguished_name]
	C = $c
	ST = $st
	L = $l
	O = $o
	OU = $o
	CN = $cn
	[server]
	authorityKeyIdentifier=keyid,issuer
	basicConstraints = critical,CA:FALSE
	extendedKeyUsage=serverAuth
	keyUsage = critical, digitalSignature, keyEncipherment
	subjectKeyIdentifier=hash
	subjectAltName = @alt_names
	[alt_names]
	DNS.1 = $cn
	DNS.2 = *.$cn
	DNS.3 = localhost
	DNS.4 = ::1
	EOR

	echo "Request:"
	
	# Generate site CSR
	# openssl req \
	# 	-new -key "$site_key" \
	# 	-out "$site_csr" -sha256 \
	# 	-subj "/C=$c/ST=$st/L=$l/O=$o/CN=$cn"

	openssl req \
		-new -key "$site_key" \
		-out "$site_csr" -sha256 \
		-config "$site_cnf"

	echo "Verify Request:"
	openssl req -noout -text -in "$site_csr"

	echo "Sign:"
	# Sign the site certificate
	openssl x509 -req -days 750 -in "$site_csr" -sha256 \
		-CA "$root_crt" -CAkey "$root_key" -CAcreateserial \
		-out "$site_crt" -extfile "$site_cnf" -extensions server
	
	cat $site_crt $root_crt > $fullchain

	# Verify certificates
	openssl verify -CAfile "$root_crt" "$site_crt"

	# Verify remote site (Takes at least 30 seconds)
	# openssl s_client -quiet -connect $cn:443

	# Show certs remote (-brief)
	# openssl s_client -showcerts -connect $cn:443
}

map() { # Map openssl-output fnames to app (YAML) names : docker secret|config name

	secrets=$(docker secret ls)
	configs=$(docker config ls)

	echo "=== openssl x509 -subject"
	openssl x509 -subject -noout < ${site_crt}

	echo "=== docker secret : Remove old"
	[[ "$(echo $secrets |grep ${TLS_SITE_KEY})" ]]  && docker secret rm ${TLS_SITE_KEY}
	[[ "$(echo $secrets |grep ${TLS_SITE_CRT})" ]]  && docker secret rm ${TLS_SITE_CRT}
	[[ "$(echo $secrets |grep ${TLS_FULLCHAIN})" ]] && docker secret rm ${TLS_FULLCHAIN}
	[[ "$(echo $configs |grep ${TLS_DHPARAM})" ]]   && docker config rm ${TLS_DHPARAM}

	echo "=== docker secret : Create new"
	docker secret create ${TLS_SITE_KEY} ${site_key}
	docker secret create ${TLS_SITE_CRT} ${site_crt}
	docker secret create ${TLS_FULLCHAIN} ${fullchain}
	docker config create ${TLS_DHPARAM} "${PATH_OUT}/../${dhparamRSA}"

	# Show
	docker secret ls |grep 'site.'
	docker config ls |grep dhparam
}

# Generate Diffie-Hellman params for web server (TEN MINUTES @ RSA length=4096)
# DEPRICATED : Not utilized @ ECC certs.
dhparamRSA='dhparam.rsa.pem'
dhparamECC='dhparam.ecc.pem'
algoECC='secp384r1'
algoECC='prime256v1'
_dhparamECC(){ openssl ecparam -name $algoECC -out $dhparamECC; }
_dhparamRSA(){ openssl dhparam -out $dhparamRSA $length; }
dhparam(){ _dhparamRSA; }

[[ -d "${PATH_OUT}" ]] || mkdir -p "${PATH_OUT}"
pushd "${PATH_OUT}"
[[ "$PWD" == "${PATH_OUT}" ]] || { echo "FAIL @ mkdir";exit 0; }

"$@"

popd