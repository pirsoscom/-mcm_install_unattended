
kubectl get navconfigurations.foundation.ibm.com multicluster-hub-nav -n kube-system -o yaml > navconfigurations.orginal

cp navconfigurations.orginal navconfigurations.demo.yaml
nano navconfigurations.demo.yaml

cat >/etc/myconfig.conf <<EOL
  - iconUrl: /common-nav/graphics/automate-infrastructure.svg
    id: demo
    label: Demo Apps
  - id: id-ldap
    label: OpenLDAP Admin
    parentId: administer-mcm
    serviceId: webui-nav
    target: _blank
    url: http://openldap-admin-default.cp4mcp-demo-002-a376efc1170b9b8ace6422196c51e491-0000.us-south.containers.appdomain.cloud/
  - id: kubetoy
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: KubeToy
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: http://kubetoy-default.mcmapp002-a376efc1170b9b8ace6422196c51e491-0001.eu-de.containers.appdomain.cloud/home
  - id: grpc-dev
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: GRPC Demo App (Dev)
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: http://grpc-web-route-grpcdemo-app.mcmapp001-a376efc1170b9b8ace6422196c51e491-0001.us-south.containers.appdomain.cloud/
  - id: grpc-prod
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: GRPC Demo App (Prod)
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: http://grpc-web-route-grpcdemo-app.mcmapp002-a376efc1170b9b8ace6422196c51e491-0001.eu-de.containers.appdomain.cloud/
  - id: modresort
    isAuthorized:
    - Administrator
    - ClusterAdministrator
    - Operator
    label: Modresort
    parentId: demo
    serviceId: mcm-ui
    target: _blank
    url: http://modresort-app-web-route-modresort-app.mcmapp002-a376efc1170b9b8ace6422196c51e491-0001.eu-de.containers.appdomain.cloud/resorts/
EOL


kubectl apply -n kube-system --validate=false -f navconfigurations.demo.yaml  