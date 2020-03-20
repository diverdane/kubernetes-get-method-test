# kubernetes-get-method-test

This repository contains scripts and a Dockerfile for creating a container
that can be used to test how the standard Ruby kubeclient can search for
an appropriate client that is capable of getting a specified Kubernetes
resource.

When the Docker container is run, it will connect with a Kubernetes server
based on the active Kubectl context. The Ruby script in the container will
then walk through a list of clients that are configured with different
Kubernetes API groups and API versions, and it will attempt to find the
first client in the list that supports get of a specified Kubernetes
resource.

## Prerequisites
To run the Kubernetes get-method test container, you'll need to have access
to a Kubernetes cluster.

If you don't have a Kubernetes cluster readily available, but you have
a Docker daemon running on a Linux / OS X host, then you can create a
Kubernetes cluster using [Kubernetes-in-Docker](https://github.com/kubernetes-sigs/kind)
(KinD). However, if you use a KinD cluster, you will need to run the
get-method test by running the `kubernetes_get_method.rb` Ruby script
directly, rather than via the test container.

## Running the Kubernetes Get-Method Test

### Configuring Kubernetes Access Credentials

In order for the test container to be able to connect with your Kubernetes
cluster, you'll need to retrieve some credentials information from your
cluster and from your cluster's config, and set that credentials in
environment variables that the test container can access.

To do this, first clone this repo so that you have a copy of the
setenv_kube_context.sh script:

    ```
    git clone https://github.com/diverdane/kubernetes-get-method-test
    ```

And then source the script to set up the credentials environment variables:

    ```
    cd kubernetes-get-method-test
    source setenv_kube_context.sh
    ```

### Select a Kubernetes Resoure to Test for Get Access
By default, the test container will test clients for their ability to
get Kubernetes pods (`get_pod` method).

To modify the resource to test against, set the `KUBE_GET_RESOURCE`
environment variable, e.g.:

    ```
    export KUBE_GET_RESOURCE="deployment"
    ```

### Running the Test via the Docker Container

If your Kubernetes cluster is not a Kubernetes-in-Docker cluster, then
you can run the get-resource test via the test Docker container.
To run the get-resource test via this container, run:

    ```
    ./command_line.sh
    ```

This will step through a list of clients configured for different
Kubernetes API groups / API versions, looking for the first client
that is capable of getting the resource specified in $KUBE_GET_RESOURCE.

The output should look something like this:

```
Getting client for method get_pod
Add client, api: api, version: v1, url: https://<Your Kubernetes Host>:8443/api
Add client, api: apis/apps, version: v1, url: https://<Your Kubernetes Host>:8443/apis/apps
Add client, api: apis/apps, version: v1beta2, url: https://<Your Kubernetes Host>:8443/apis/apps
Add client, api: apis/apps, version: v1beta1, url: https://<Your Kubernetes Host>:8443/apis/apps
Add client, api: apis/extensions, version: v1, url: https://<Your Kubernetes Host>:8443/apis/extensions
Add client, api: apis/extensions, version: v1beta1, url: https://<Your Kubernetes Host>:8443/apis/extensions
Add client, api: oapi, version: v1, url: https://<Your Kubernetes Host>:8443/oapi
Add client, api: apis/apps.<Your Kubernetes Host>:8443/apis/apps.openshift.io
===========================================================
Method get_pod is supported for client: api_group: , api_version: v1, entities: ---
binding: !ruby/object:OpenStruct
  table:
    :entity_type: Binding
    :resource_name: bindings
    :method_names:
    - binding
    - bindings
component_status: !ruby/object:OpenStruct
  table:
    :entity_type: ComponentStatus
    :resource_name: componentstatuses
    :method_names:
    - component_status
    - component_statuses
config_map: !ruby/object:OpenStruct
  table:
    :entity_type: ConfigMap
    :resource_name: configmaps
    :method_names:
    - config_map
    - config_maps
endpoint: !ruby/object:OpenStruct
  table:
    :entity_type: Endpoint
    :resource_name: endpoints
    :method_names:
    - endpoint
    - endpoints
event: !ruby/object:OpenStruct
  table:
    :entity_type: Event
    :resource_name: events
    :method_names:
    - event
    - events
limit_range: !ruby/object:OpenStruct
  table:
    :entity_type: LimitRange
    :resource_name: limitranges
    :method_names:
    - limit_range
    - limit_ranges
namespace: !ruby/object:OpenStruct
  table:
    :entity_type: Namespace
    :resource_name: namespaces
    :method_names:
    - namespace
    - namespaces
node: !ruby/object:OpenStruct
  table:
    :entity_type: Node
    :resource_name: nodes
    :method_names:
    - node
    - nodes
persistent_volume_claim: !ruby/object:OpenStruct
  table:
    :entity_type: PersistentVolumeClaim
    :resource_name: persistentvolumeclaims
    :method_names:
    - persistent_volume_claim
    - persistent_volume_claims
persistent_volume: !ruby/object:OpenStruct
  table:
    :entity_type: PersistentVolume
    :resource_name: persistentvolumes
    :method_names:
    - persistent_volume
    - persistent_volumes
pod: !ruby/object:OpenStruct
  table:
    :entity_type: Pod
    :resource_name: pods
    :method_names:
    - pod
    - pods
pod_template: !ruby/object:OpenStruct
  table:
    :entity_type: PodTemplate
    :resource_name: podtemplates
    :method_names:
    - pod_template
    - pod_templates
replication_controller: !ruby/object:OpenStruct
  table:
    :entity_type: ReplicationController
    :resource_name: replicationcontrollers
    :method_names:
    - replication_controller
    - replication_controllers
resource_quota: !ruby/object:OpenStruct
  table:
    :entity_type: ResourceQuota
    :resource_name: resourcequotas
    :method_names:
    - resource_quota
    - resource_quotas
secret: !ruby/object:OpenStruct
  table:
    :entity_type: Secret
    :resource_name: secrets
    :method_names:
    - secret
    - secrets
security_context_constraint: !ruby/object:OpenStruct
  table:
    :entity_type: SecurityContextConstraint
    :resource_name: securitycontextconstraints
    :method_names:
    - security_context_constraint
    - security_context_constraints
service_account: !ruby/object:OpenStruct
  table:
    :entity_type: ServiceAccount
    :resource_name: serviceaccounts
    :method_names:
    - service_account
    - service_accounts
service: !ruby/object:OpenStruct
  table:
    :entity_type: Service
    :resource_name: services
    :method_names:
    - service
    - services
===========================================================
Acceptable client found for method get_pod
   api_group:   
   api_version: v1
===========================================================
```

### Running the Test Script Directly (e.g. for KinD Clusters)

If your Kubernetes cluster is a KinD cluster, then it is running as
one or more Docker containers that each function as a Kubernetes node.
For this configuration, the Kubernetes API controller will be serving
on localhost address 127.0.0.1, e.g.:

    ```
    $ kubectl cluster-info
    Kubernetes master is running at https://127.0.0.1:32770
    KubeDNS is running at https://127.0.0.1:32770/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
    $ 
    ```

In this case, the easiest way to run the tests is to run the
`kubernetes_get_method.rb` Ruby script directly by running the following:

    ```
    ruby kubenetes_get_method.rb
    ```

The resulting output should be similar to that shown above.
