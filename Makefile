##############################################################################
ABOUT := TLS : openssl : self-signed cert
##############################################################################
# Include project root settings
include ./../../../../Makefile.settings
#include Makefile.settings

##############################################################################
# Meta
#export DOMAIN := swarm.foo

menu :
	$(INFO) '${ABOUT}'
	$(INFO) 'Create self-signed certificate : "$${DOMAIN}"'
	@echo '	cert    : openssl … -subj "…/CN=${DOMAIN}"'
	$(INFO) 'Other recipes'
	@echo '	map     : Map acme.sh-output fnames to app names : docker create {secret|config} name'
	@echo '	ls      : ls -ahl $${PATH_OUT} + docker secrets/configs'
	@echo '	dhparam : openssl … (Generate DH-param file; RSA|ECC)'

env :
	@env |grep DOMAIN
	@env |grep PATH_OUT

##############################################################################
# openssl 

export PATH_OUT  := ${PWD}/${DOMAIN}_ecc
# TLS params
# key length : 4096 (RSA) | ec-384 (Elliptic Curve)
# export LEN := ec-384

cert :
	bash make.openssl.sh cert
	
dhparam :
	bash make.openssl.sh dhparam

ls :
	ls -ahl ${PATH_OUT}
	docker secret ls |grep 'site.'
	docker config ls |grep dhparam

map :
	bash make.openssl.sh map