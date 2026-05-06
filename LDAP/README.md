# Deploy LDAP Server on OpenShift


~~~
oc new-app --name openldap ALLOW_EMPTY_PASSWORD=yes --image docker.io/osixia/openldap:latest
don't need to set variables, default are
-e LDAP_ADMIN_PASSWORD=password0 -e LDAP_ADMIN_USERNAME=admin -e LDAP_ADMIN_PASSWORD=passwordany
~~~

Create a service account named openldap-sa
~~~
oc create sa openldap-sa

#Assign the anyuid SCC to the openldap-sa service account.
oc adm policy add-scc-to-user anyuid -z openldap-sa

#Assign service account to deployment
oc set serviceaccount deployment/openldap openldap-sa

#Verify
oc get deploy/openldap -o yaml | oc adm policy scc-subject-review -f -

#log into the container
oc exec -it pods/<ldap-pod> bash

#execute a ldapsearch
ldapsearch -x -H ldap://localhost:389 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin
~~~

