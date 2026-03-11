## 1. Set variables
~~~
PROJECT_NAME=camel-producer
DIR_NAME=JMSCamelProducer
~~~

## 2. Create imagestream.yaml
~~~
oc apply -f imagestream.yaml
~~~

## 3. Create build.yaml
~~~
oc apply -f build.yaml
~~~

## 4. Apply and Push to OpenShift
~~~
oc apply -f imagestream.yaml
oc apply -f build.yaml
oc start-build ${PROJECT_NAME} --from-dir=${DIR_NAME} --follow
oc new-app ${PROJECT_NAME}
~~~

