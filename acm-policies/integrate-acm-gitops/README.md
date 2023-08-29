## Install gitops/argoCD and integrate into RHACM
### NOTE: The following documentation is terrible. Several steps are duplicated.
### https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/applications/index#register-gitops

### Step 1 - Create ManagedClusterSet
#### NOTE: These steps assume a clusterset has already been created and the hub cluster assigned. This was done in the "install-acm" step. And this assumed the clusterSet is named "hub".

### Step 2 - Create managed cluster set binding to the namespace where gitops was installed, normally openshift-gitops
```bash
oc apply -f ../integrate-acm-gitops/managedclustersetbinding-hub-openshift-gitops.yaml
```
### Step 3 - Create placement in the namespace where gitops was installed, normally openshift-gitops
### NOTE: This placement has a spec for clusterSets that is not in the documentation. This is because of this issue:
### https://issues.redhat.com/browse/ACM-6270
```bash
oc apply -f ../placement-hub-gitops.yaml
```

### Step 4 -  Create GitOpsCluster CRD
```bash
oc apply -f ../gitopscluster.yaml
```
