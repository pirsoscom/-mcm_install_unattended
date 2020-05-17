# Install Script for IBM Cloud Pack for Multicloud Management on OCP 4.3


> USAGE 1\_install\_all.sh **-t** \<REGISTRY\_TOKEN\> **-x** \<OCP\_CONSOLE\_PREFIX\> **-s** \<STORAGE\_CLASS\> **-p** \<MCM\_PASSWORD\> **-l** \<LDAP\_ADMIN\_PASSWORD\> [**-h** \<CLUSTER\_NAME\>] [**-d** \<TEMP\_DIRECTORY\>] [**-c** \<CLOUDFORMS\_URL\>] [**-a** \<INSTALL\_ANSIBLE (yes)\>]

```


./1_install_all.sh -t MY_TOKEN -x console-openshift-console -s ibmc-block-gold -p passw0rd -l passw0rd -d /tmp/mcm-install [-c https://<CF_IP>] [-a yes]

```


___

### Separate installations

```
./2_install_mcm.sh -t MY_TOKEN -d /tmp/mcm-install -p passw0rd
./3_install_cam.sh -t MY_TOKEN -d /tmp/mcm-install -x console-openshift-console -p passw0rd
./4_install_apm.sh -t MY_TOKEN -d /tmp/mcm-install -x console-openshift-console -p passw0rd

./8_install_ldap.sh -d /tmp/mcm-install -x console-openshift-console -p passw0rd

kubectl apply -f tools/apm/kubetoy_all_in_one.yaml -n default

```