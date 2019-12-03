```shell script
# Create applications
oc new-project app-a
oc new-app httpd-example -n app-a
oc new-project app-b
oc new-app httpd-example -n app-b

# Set environment specific parameters
this_cluster_api_url=https://api.ocp4north.example.domain:6443
alternate_cluster_api_url_list=https://api.ocp4east.example.domain:6443,https://api.ocp4west.example.domain:6443
deployment_name=httpd-example
app_project=app-a

# Deploy CronJob
oc process -f job_template.yaml \
  -p THIS_CLUSTER_API_URL=${this_cluster_api_url} \
  -p ALTERNATE_CLUSTER_API_URL_LIST=${alternate_cluster_api_url_list} \
  -p deployment_name=httpd-example \
  | oc create -n ${app_project} -f -

# Build CronJob image
oc start-build ha-cronjob-${deployment_name} -n ${app_project} 
```

