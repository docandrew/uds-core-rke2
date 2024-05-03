

# Generate self-signed TLS certificate for testing
# Usage: make cert
.PHONY: cert
cert: tls.cert tls.key

tls.cert tls.key:
	openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.cert -days 365 -nodes -config tls-cert.conf
