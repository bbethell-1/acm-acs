## RHACM DR
### References
#### https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.8/html-single/business_continuity/index
#### https://github.com/stolostron/cluster-backup-operator
#### https://cloud.redhat.com/blog/backup-and-restore-hub-clusters-with-red-hat-advanced-cluster-management-for-kubernetes
#### https://github.com/open-cluster-management-io/policy-collection/tree/main/community/CM-Configuration-Management/acm-app-pv-backup
#### https://cloud.redhat.com/blog/how-to-backup-and-restore-acm-with-oadp-and-minio
#### https://docs.openshift.com/container-platform/4.12/backup_and_restore/application_backup_and_restore/installing/installing-oadp-aws.html



### Assumes ACM is installed on both primary and backup clusters - IN THE SAME NAMESPACES
### All operators installed on primary must also be installed on backup
#### example: Ansible Automation Platform, Red Hat OpenShift GitOps, cert-manager

## Steps
### Active and Passive clusters
#### Install backup and restore operator and set cluster-backup to true
### Passive cluster
#### Create the DataProtectionApplication resource and connect to the same storage location where the initial hub cluster backed up data.
################

## Install OADP Operator # It will be installed by setting cluster-backup = true in the mch
```bash
oc patch MultiClusterHub multiclusterhub -n open-cluster-management --type=json -p='[{"op": "add", "path": "/spec/overrides/components/-","value":{"name":"cluster-backup","enabled":true}}]'
oc get csv -n open-cluster-management-backup |grep OADP
```

## Download aws cli
### https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# Test
aws --version
```

## Create bucket and access to it
### Set the BUCKET variable:
```bash
BUCKET=rhacm-dr-test-mmw
```
### Set the REGION variable:
```bash
REGION=us-east-2
```
### Create an AWS S3 bucket:
```bash
aws s3api create-bucket --bucket $BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
```
#v# Create an IAM user:
```bash
aws iam create-user --user-name velero
```
### Create a velero-policy.json file:
```bash
cat > velero-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}"
            ]
        }
    ]
}
EOF
```

### Attach the policies to give the velero user the minimum necessary permissions:
```bash
aws iam put-user-policy --user-name velero --policy-name velero --policy-document file://velero-policy.json
```
### Create an access key for the velero user:
```bash
# NOTE. The first command creates the access key and stores the secret in the variable.
AWS_SECRET_ACCESS_KEY=$(aws iam create-access-key --user-name velero --output text | awk '{print $4}')
AWS_ACCESS_KEY_ID=$(aws iam list-access-keys --user-name velero --output text | tail -1 | awk '{print $2}')
echo $AWS_SECRET_ACCESS_KEY
echo $AWS_ACCESS_KEY_ID
```

### List access key value just created (NOTE, you cannot get the SECRET_ACCESS_KEY after the initial creation)
```bash
aws iam list-access-keys --user-name velero
```
### If you have an issue, you can delete the access key and recreate showing the full output:
```bash
aws iam list-access-keys --user-name velero
aws iam delete-access-keys --access-key-id <ACCESS KEY ID> --user-name velero
aws iam create-access-key --user-name velero
```
### Example output
```
{
  "AccessKey": {
        "UserName": "velero",
        "Status": "Active",
        "CreateDate": "2017-07-31T22:24:41.576Z",
        "SecretAccessKey": <AWS_SECRET_ACCESS_KEY>,
        "AccessKeyId": <AWS_ACCESS_KEY_ID>
  }
}
```
### Actual
```
{
    "AccessKey": {
        "UserName": "velero",
        "AccessKeyId": "AKIAYDLESQHDO42DI7HI",
        "Status": "Active",
        "SecretAccessKey": "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",
        "CreateDate": "2023-08-31T13:55:34+00:00"
    }
}
```
### Create a credentials-velero file:
```bash
cat << EOF > ./credentials-velero
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOF
```

### Create a Secret with the default name:
```bash
# oc create secret generic cloud-credentials -n openshift-adp --from-file cloud=credentials-velero
oc create secret generic cloud-credentials -n open-cluster-management-backup --from-file cloud=credentials-velero
```

## Create DataProtectionApplication CR
```bash
oc apply -f acm-dr/dpa.yaml
```


# OLD


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