## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
```bash
oc apply -f patch-subscription-admin.yaml
```

## Create ACM application to run policies
```bash
oc apply -f main-policy.yaml
bash
