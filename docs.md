# Initial Node
`curl -fL https://get.k3s.io | sh -s - server --cluster-init --token 5812F38EB47449D5 --tls-san saturn.kube.markmckessock.com --disable servicelb --disable traefik --disable local-storage --write-kubeconfig-mode 644`
# Additional Nodes
`curl -fL https://get.k3s.io | sh -s - server --server https://kari.saturn.kube.markmckessock.com:6443 --token 5812F38EB47449D5 --write-kubeconfig-mode 644 --node-name $HOSTNAME --disable servicelb --disable traefik --disable local-storage`

# Flux install
`flux bootstrap github --owner markmckessock --repository kube-saturn --path cluster --personal`
# Bootstrap flux age key
`cat age.agekey | kubectl -n flux-system create secret generic sops-age --from-file=age.agekey=/dev/stdin`