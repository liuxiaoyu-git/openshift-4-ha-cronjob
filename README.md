```shell script
oc new-project app-a
oc new-project app-b
oc new-app httpd-example -n app-a
oc new-app httpd-example -n app-b

oc process -f job_template.yaml \
  -p VAR=VALUE \
  | oc create -n app-a -f -
```

