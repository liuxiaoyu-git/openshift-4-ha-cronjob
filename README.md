# OpenShift 4 HA CronJob

OpenShift template to deploy a CronJob suitable for maintaining a desired number of application replicas accross multiple OpenShift clusters.

## What problem does this solve?

To maintain a consistent number of stateless application replicas across multiple OpenShift clusters, tolerant to cluster failure.

## How does it work?

The main mechanism that achieves this goal is a [CronJob](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html) running alongside each application [Deployment/DeploymentConfig](https://docs.openshift.com/container-platform/latest/applications/deployments/what-deployments-are.html) in each cluster.

The CronJob is given the Cluster API URL for each external cluster and monitors their [/healthz](https://github.com/openshift/origin/blob/master/docs/proposals/instrumentation-of-services.md) endpoint. When a non ```200 ok``` response is detected the number of application replicas is adjusted to ensure a consistent number of replicas across all remaining clusters.

![Diagram](diagram.png)

For example lets use the situation where there are 3 OpenShift clusters with 2 application replicas in each.

If a single cluster goes down each remaining cluster will increase its capacity by 1.
If two clusters go down the remaining cluster will increase its capacity by 4.

When the CronJob detects that the alternate clusters are helathy they will scale the application back down to its original replica count.

## Quickstart 

The following should be done for each OpenShift cluster. 

```shell script
# Create application
oc new-project app-a
oc new-app httpd-example -n app-a

# Set environment specific parameters - replace with parameters relevant to your environment
this_cluster_api_url=https://api.ocp4north.example.domain:6443
alternate_cluster_api_url_list=https://api.ocp4east.example.domain:6443,https://api.ocp4west.example.domain:6443
deployment_name=httpd-example
deployment_project=app-a

# Grant service account permission to allow CronJob to scale application replicas
oc policy add-role-to-user edit system:serviceaccount:${app_project}:ha-cronjob-${deployment_name} -n ${app_project}

# Deploy template - there are more than the below parameters
oc process -f job_template.yaml \
  -p DEPLOYMENT_PROJECT=${deployment_project} \
  -p THIS_CLUSTER_API_URL=${this_cluster_api_url} \
  -p ALTERNATE_CLUSTER_API_URL_LIST=${alternate_cluster_api_url_list} \
  -p DEPLOYMENT_NAME=${deployment_name} \
  | oc create -n ${deployment_project} -f -
```

## Template Parameters

The list of parameters this template accepts can be listed with the following command:

```shell script
oc process --parameters -f job_template.yaml
```

## Adding additional functionality

The core logic of this is contained in the ansible playbook that gets run in the Job container, which is defined as a ConfigMap in this template. It would be trivial to extend the functionality of this by adding additional logic to the ansible playbook. 

## Miscellaneous Useful Commands
```shell script
# Set environment specific parameters - replace with parameters relevant to your environment
deployment_name=httpd-example
deployment_project=app-a

# Build CronJob image
oc start-build ha-cronjob-${deployment_name} -n ${deployment_project} 

# Create job manually
oc create job -n ${deployment_project} --from=cronjob/ha-cronjob-${deployment_name} ha-cronjob-${deployment_name}-manual
```

