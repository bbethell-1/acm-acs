# Prereqs to be run from CLI
## To install ACM on hub cluster
## (Check version of ACM in subscription within the file installhub.sh)
```bash
cd prereqs
. ./installhub.sh
```
## Create clusterset for hub
```bash
oc apply -f create-clusterset-hub.yaml
```

## Assign new clusterset to hub cluster
```bash
. ./clusterset-label-hub-local-cluster.sh
```

## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
```bash
oc apply -f patch-subscription-admin.yaml
```

# Now create the application

## Create acm-policies namespace
```
oc new-project acm-policies
```

## Create ACM application to run policies
```bash
oc apply -f main-policy.yaml
```

## For policy generator
### Test at cli - follow these steps (examples below)
#### https://github.com/open-cluster-management-io/policy-generator-plugin/tree/main

### Download PolicyGenerator to ~/Downloads
#### https://github.com/open-cluster-management-io/policy-generator-plugin/releases
### Install go


```bash
mkdir -p ${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator
chmod +x ~/Downloads/linux-amd64-PolicyGenerator
mv linux-amd64-PolicyGenerator ${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator/PolicyGenerator
sudo dnf install go # may need to connect to VPN first
GOBIN=${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator \
go install open-cluster-management.io/policy-generator-plugin/cmd/PolicyGenerator@latest
make build
