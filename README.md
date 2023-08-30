# Install ACM on hub cluster
## Prereqs to be run from CLI
## clone git repo
```bash
mkdir ~/git
cd ~/git
git clone https://github.com/mmwillingham/acm-acs.git
cd acm-acs
```
## To install ACM on hub cluster
## (Check version of ACM in subscription within the file installhub.sh)
```bash
. install-acm/installhub.sh
```
## Create clusterset for hub
```bash
oc apply -f install-acm/create-clusterset-hub.yaml
```

## Assign new clusterset to hub cluster
```bash
. install-acm/clusterset-label-hub-local-cluster.sh
```

## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
```bash
oc apply -f install-acm/patch-subscription-admin.yaml
```

# Now create the ACM application subscription

## Create acm-policies namespace
```bash
oc new-project acm-policies
```

## Create ACM application to run policies
```bash
oc apply -f base/main-policy.yaml
```


## The following steps are optional.
## For policy generator - if using native ACM application, no need to enable policyGenerator
### Test at cli - follow these steps (examples below)
#### https://github.com/open-cluster-management-io/policy-generator-plugin/tree/main
### These steps are shorter for installing policyGenerator
#### https://cloud.redhat.com/blog/generating-governance-policies-using-kustomize-and-gitops

### Download PolicyGenerator to ~/Downloads
#### https://github.com/open-cluster-management-io/policy-generator-plugin/releases

### Install PolicyGenerator
```bash
mkdir -p ${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator
chmod +x ~/Downloads/linux-amd64-PolicyGenerator
mv linux-amd64-PolicyGenerator ${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator/PolicyGenerator
sudo dnf install go # may need to connect to VPN first
GOBIN=${HOME}/.config/kustomize/plugin/policy.open-cluster-management.io/v1/policygenerator \
go install open-cluster-management.io/policy-generator-plugin/cmd/PolicyGenerator@latest
```

### Test at CLI - two methods
#### As a plugin
cd base
kustomize build --enable-alpha-plugins

#### Directly at a policyGenerator config
PolicyGenerator policygenerator.yaml


