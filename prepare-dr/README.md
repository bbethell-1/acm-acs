## RHACM DR
### References
#### https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/business_continuity/index
#### https://github.com/stolostron/cluster-backup-operator
#### https://cloud.redhat.com/blog/backup-and-restore-hub-clusters-with-red-hat-advanced-cluster-management-for-kubernetes

### Assumes ACM is installed on both primary and backup clusters - IN THE SAME NAMESPACES
### All operators installed on primary must also be installed on backup
#### example: Ansible Automation Platform, Red Hat OpenShift GitOps, cert-manager

## Steps
### Configure cloud storage
#### Create default secret for the cloud storage. Must be created in the OADP operator namespace.
### Active and Passive clusters
#### Install backup and restore operator and set cluster-backup to true
### Passive cluster
#### Create the DataProtectionApplication resource and connect to the same storage location where the initial hub cluster backed up data.


##### Operators > Installed Operators
Click Create instance under DataProtectionApplication
Create the Velero instance by selecting configurations using the {ocp-short) console or by using a YAML file as mentioned in the DataProtectionApplication example.
Set the DataProtectionApplication namespace to open-cluster-management-backup.
Set the specification (spec:) values appropriately for the DataProtectionApplication resource. Then click Create.
If you intend on using the default backup storage location, set the following value, default: true in the backupStorageLocations section. View the following DataProtectionApplication resource sample:
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: dpa-sample
spec:
  configuration:
    velero:
      defaultPlugins:
      - openshift
      - aws
    restic:
      enable: true
  backupLocations:
    - name: default
      velero:
        provider: aws
        default: true
        objectStorage:
          bucket: my-bucket
          prefix: my-prefix
        config:
          region: us-east-1
          profile: "default"
        credential:
          name: cloud-credentials
          key: cloud
  snapshotLocations:
    - name: default
      velero:
        provider: aws
        config:
          region: us-west-2
          profile: "default"

### Enable the backup and restore operator
The cluster backup and restore operator can be enabled when the MultiClusterHub resource is created for the first time. The cluster-backup parameter is set to true. When the operator is enabled, the operator resources are installed.

If the MultiClusterHub resource is already created, you can install or uninstall the cluster backup operator by editing the MultiClusterHub resource. Set cluster-backup to false, if you want to uninstall the cluster backup operator.

### Restore
- Shut down the primary cluster.
- See Shutting down the primary cluster for more information.
- If you want to use an existing managed cluster as the restore hub, set disableHubSelfManagement to true in the MultiClusterHub.
- For more information, see the disableHubSelfManagement topic.
- See the following example where spec.disableHubSelfManagement is set to true:
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: <namespace>
spec:
  disableHubSelfManagement: true