#1 load image in podman
$podman load -i image.tar.gz

$podman images
REPOSITORY                                                                       TAG         IMAGE ID      CREATED        SIZE
registry.eng.com/amq-broker-7-amq-broker-714-openshift-rhel9                     7.14        2e4367fe5000  3 days ago     631 MB


# 1. Variables
export REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
export NAMESPACE=$(oc project -q)
export IMAGE_ID="2e4367fe51f0"
export IMAGE_NAME="amq-broker"
export IMAGE_TAG="7.14.0-4"

# 2. Login
podman login -u unused -p $(oc whoami -t) $REGISTRY --tls-verify=false
Login Succeeded!

# 3. Tag
podman tag $IMAGE_ID $REGISTRY/$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG

# 4. Push
podman push $REGISTRY/$NAMESPACE/$IMAGE_NAME:$IMAGE_TAG --tls-verify=false
