#This is an example to pull and push quay images in a OCP repository of a disconnected environment.


# STEP 0: Run these commands on an internet-connected workstation:

podman pull quay.io/prometheus/prometheus:v2.55.1
podman save -o prometheus-v2.55.1.tar.gz quay.io/prometheus/prometheus:v2.55.1

# Inspect the loaded image to grab its IMAGE ID:
podman images | grep prom
# REPOSITORY                       TAG       IMAGE ID       CREATED       SIZE
quay.io/prometheus/prometheus    v2.55.1    899b369f202e  23 months ago  291 MB

# [Transfer prometheus-v2.55.1.tar.gz to your disconnected jump host/bastion]

# STEP 1: Load Image on Disconnected Host
podman load -i prometheus-v2.55.1.tar.gz

# STEP 2: Configure OpenShift Internal Registry Route
# Expose the internal registry default route (must be done before fetching $REGISTRY). Normally external clients as Podman and Docker cannot access to the registry. So this command create an external route for the registry.
# You can check the routes with `oc get route default-route -n openshift-image-registry`.
# And you can disable it (for security reason) after you finish the procedure with `oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":false}}'` and verify it is gone with: `oc get route default-route -n openshift-image-registry`.

oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge


# STEP 3: Set Variables
export REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
export NAMESPACE=$(oc project -q)

# Set Prometheus-specific metadata (replace IMAGE_ID with your actual 'podman images' ID output)
export IMAGE_ID="899b369f202e"
export IMAGE_NAME="prometheus"
export IMAGE_TAG="v2.55.1"


# STEP 4: Login to OpenShift Registry
podman login -u unused -p $(oc whoami -t) $REGISTRY --tls-verify=false
# Output: Login Succeeded!

# STEP 5: Tag & Push Image
podman tag $IMAGE_ID $REGISTRY/$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG

# Push to OpenShift internal registry
podman push $REGISTRY/$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG --tls-verify=false


# Verify and find the image reference
$oc get all
[...]
NAME                                        IMAGE REPOSITORY                                                      TAGS      UPDATED
imagestream.image.openshift.io/prometheus   image-registry.openshift-image-registry.svc:5000/streams/prometheus   v2.55.1   6 seconds ago

# Update the deployment updating the YAML

spec:
  template:
    spec:
      containers:
      - name: prometheus
        image: image-registry.openshift-image-registry.svc:5000/streams/prometheus:v2.55.1

# Or patch directly the Deployment
oc set image deployment/<deployment-name> <container-name>=<new-image-path> -n <namespace>
~~~
