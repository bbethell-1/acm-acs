## To install ACM on hub cluster
## (Check version of ACM in subscription within the file installhub.sh)
```bash
installhub.sh
```
## Create clusterset for hub
```bash
create-clusterset-hub.yaml
```

## Assign new clusterset to hub cluster
```bash
clusterset-label-hub-local-cluster.sh
```

## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
```bash
oc apply -f patch-subscription-admin.yaml
```

## Create ACM application to run policies
```bash
oc apply -f main-policy.yaml
```
