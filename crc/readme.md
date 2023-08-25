## Add kubeadmin (and other desired users) to subscription-admin cluster-role-binding
oc apply -f patch-subscription-admin.yaml

## Create ACM application to run policies
oc apply -f main-policy.yaml

