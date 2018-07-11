# Advanced PaaS Administration Training Homework Doc

## Provisioned Homework Environment

This homework lab is done on the premise that it has an environment described as follows.

### Provisioned Environment Hosts

* Bastion host
  * bastion.$GUID.example.opentlc.com, bastion.$GUID.internal
* 3 master nodes
  * master[1:3].$GUID.internal
* 1 loadbalancer node
  * loadbalancer1.$GUID.internal
* 2 infranodes
  * infranode[1:2].$GUID.internal
* 3 worker nodes
  * node[1:3].$GUID.internal
* 1 support node
  * support1.$GUID.internal

* Can access to all hosts from bastion via ssh without password
* Can be root user without password
* Ansible is installed on all hosts
* Docker is installed and running on all nodes

#### Check if Docker is running on each node

```shell
ansible -i hosts nodes -m shell -a"systemctl status docker | grep Active"
```

## Basic and HA Requirements, Environment Configuration

As the root user on bastion, run the following commands to create OpenShift HA environment.

```shell
git clone https://github.com/hisasue/ocp_advanced_deployment_assignment.git
cd ocp_advanced_deployment_assignment

chmod u+x do.sh

./do.sh
```

* In this environment:
  * Three masters are working
  * Three etcd instances working on master nodes
  * Master console has an ability to authenticate
  * Registry with 20Gi storage is working
  * Router is configured on each infranode
  * PVs of 5Gi, ReadWriteOnce and 10Gi ReadWriteMany are available on support node
  * A load balancer to access the masters called loadbalancer.$GUID.$DOMAIN
  * There is a load balancer/DNS for both infranodes called *.apps.$GUID.$DOMAIN
  * Two infranodes, labeled env=infra
  * Ability to deploy a simple app (nodejs-mongo-persistent)
  * Multitenancy is enabled
  * Aggregated logging is configured and working
  * Metrics collection is configured and working
  * Router and Registry Pods run on Infranodes
  * Metrics and Logging components run on Infranodes
  * Service Catalog, Template Service Broker, and Ansible Service Broker are all working

You can check if the environment can be deployed an application by running following commands.

```shell
oc new-project smoke-test
oc new-app nodejs-mongo-persistent
watch oc get pod
oc get route
oc delete project smoke-test
```

## CICD Workflow

### CI/CD Pipeline

* In this section the script:
  * Creates a project (pipeline-project)
  * Creates Jenkins (persistent) Pod and run a sample app(sample-pipeline) which has build pipeline.
  * Starts the pipeine

You can see pipeline on the web console or the Jenkins console.

Web console
<https://loadbalancer.$GUID.example.opentlc.com/>

ID: webadmin
PW: r3dh4t1!

Jenkins Console
<https://jenkins-pipeline-project.apps.$GUID.example.opentlc.com/>

ID: webadmin
PW: r3dh4t1!

If you need to delete the project, run the command below.

```shell
oc delete project pipeline-project
```

## HPA is configured and working on production deployment

* In this section the script:
  * Creates a project (hpa-project)
  * Sets a LimitRange
  * Creates an HPA scaling from 1 pod minimum to 5 pod maximum up when the CPU utilization equal or greater than 80%

You can access the app to follow the link below.

<https://hello-openshift-hpa-project.apps.$GUID.example.opentlc.com/>

If you need to delete the project, run the command below.

```shell
oc delete project hpa-project
```

## Multitenancy

* Created users Amy, Andrew, Brian and Betty
* Amy and Andrew labeled client=alfa
* Brian and Betty labeld client=beta
* The new project template has a LimitRange
* admissionControl plugin sets specific limits per label (client)
  * client=alfa: Project limits max 10
  * client=beta: Project limits max 5
  * others: Project limits max 2
  * admins: No limits

The new user created with template is labeled 'common' if CLIENT_NAME is not specified.

```shell
oc process -f files/default-user-template.yaml -p USER_NAME=<username> -p CLIENT_NAME=<clientname> | oc -f -
```

* On-boarding new client can create a new client/customer as follows

```shell
ansible -i host masters -m shell -a"htpasswd -b /etc/origin/master/htpasswd <username> <passowrd>"
```

```shell
oc process -f files/default-user-template.yaml -p USER_NAME=<username> -p CLIENT_NAME=<clientname> | oc -f -
```