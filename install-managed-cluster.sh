#!/bin/bash

# This must be run on the hub cluster
clustername=prod01

# Create project for the managed cluster
# The double command will ensure the command will exit 0
oc new-project $clustername || oc project $clustername

# Create the yaml. NOTE: it is no longer necessary to label the namespace
cat << EOF > managed-cluster-$clustername.yaml
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: $clustername
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF

oc apply -f managed-cluster-$clustername.yaml

oc get secret ${CLUSTER_NAME}-import -n ${CLUSTER_NAME} -o jsonpath={.data.crds\\.yaml} | base64 --decode > klusterlet-crd.yaml
oc get secret ${CLUSTER_NAME}-import -n ${CLUSTER_NAME} -o jsonpath={.data.import\\.yaml} | base64 --decode > import.yaml

cat << EOF > klusterlet-addon-config.yaml
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: <cluster_name>
  namespace: <cluster_name>
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  EOF
  oc apply -f klusterlet-addon-config.yaml
  oc get pod -n open-cluster-management-agent-addon
    
