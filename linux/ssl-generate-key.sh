defaultName="server"
read -p "Key name [$defaultName]: " name
name=${name:-$defaultName}

while true; do
	read -p "Do you wish to encrypt the private key with a password [Yn]? " yn
	yn=${yn:-Y}
	case $yn in
		# Create the Private key with a password
		[Yy]* ) openssl genrsa -des3 -out "$name.key" 1024; break;;
		# Create the Private key without a password
		[Nn]* ) openssl genrsa -out "$name.key" 1024; break;;
		* ) ;;
	esac
done

# Remove the password and encryption from your private key
# openssl rsa -in "$name.key" -out "$name.key"

# Create the Certificate Signing Request (PKCS#10 X.509 Certificate Signing Request (CSR) Management)
openssl req -new -key "$name.key" -out "$name.csr"
# Self-Sign the Certificate (X.509 Certificate Data Management)
openssl x509 -req -days 365 -in "$name.csr" -signkey "$name.key" -out "$name.crt"
# Create the PEM file
cat "$name.key" "$name.crt" > "$name.pem"

