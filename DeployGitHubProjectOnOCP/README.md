


## 1. apply template.yaml that combinese ImageStream and BuildConfig with parameters
~~~
oc apply -f template.yaml
~~~

## 2. Using variables
### 2.1 Option1: using default
~~~
oc process -f template.yaml | oc apply -f -**
~~~

### 2.1 Option2: override variables
~~~
oc process -f template.yaml \
    -p APP_NAME=my-new-app \
    -p GIT_CONTEXT_DIR=OtherSubfolder \
    | oc apply -f -
~~~

## 3. Build
~~~
# Apply the template-generated configuration
oc process -f template.yaml | oc apply -f -

# Start the build using the name defined in the variable (default: camel-producer)
oc start-build camel-producer --follow
~~~

