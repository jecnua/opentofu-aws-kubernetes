#!/bin/bash

# As sudo on the controller box
sudo su

USERNAME=${1:-'user'}
GROUP=${2:-'system:masters'} # Admin!

# Generate random key
openssl genrsa -out "$USERNAME.key" 2048

# Add yourself on the specified group
openssl req -new \
  -key "$USERNAME.key" \
  -out "$USERNAME.csr" \
  -subj "/CN=$USERNAME/O=$GROUP"

# Sign
openssl x509 -req \
  -in "$USERNAME.csr" \
  -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial \
  -out "$USERNAME.crt" -days 10000

# Generate file
# touch "$USERNAME.data"
# echo "CA CRT:" > "$USERNAME.data"
# base64 -w0 /etc/kubernetes/pki/ca.crt >> "$USERNAME.data"
# echo "" >> "$USERNAME.data"
# echo "$USERNAME CRT:" >> "$USERNAME.data"
# base64 -w0 "$USERNAME.crt" >> "$USERNAME.data"
# echo "" >> "$USERNAME.data"
# echo "$USERNAME KEY:" >> "$USERNAME.data"
# base64 -w0 "$USERNAME.key" >> "$USERNAME.data"
# echo "" >> "$USERNAME.data"

cat <<EOF > "$USERNAME.conf"
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(base64 -w0 /etc/kubernetes/pki/ca.crt)
    server: https://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    #namespace: testing
    user: $USERNAME
  name: $USERNAME@kubernetes
current-context: $USERNAME@kubernetes
kind: Config
preferences: {}
users:
- name: $USERNAME
  user:
    client-certificate-data: $(base64 -w0 "$USERNAME.crt")
    client-key-data: $(base64 -w0 "$USERNAME.key")
EOF

cat "$USERNAME.conf"
