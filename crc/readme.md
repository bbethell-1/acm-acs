## To install ACM on hub cluster
## (Check version of ACM in subscription within the file installhub.sh)
```bash
installhub.sh
```
## Create clusterset for hub
TBD

## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
```bash
oc apply -f patch-subscription-admin.yaml
```

## Create ACM application to run policies
```bash
oc apply -f main-policy.yaml
```
