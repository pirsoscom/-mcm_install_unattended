# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Installing Script for all CP4MCM components
#
# V1.0 
#
# ©2020 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"

source ./0_variables.sh

# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo " ${CYAN} Cloud Pak for Multicloud Management${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN} Installing all components of CloudPack for Multicloud Management${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "


# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# GET PARAMETERS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo "${CYAN}***************************************************************************************************************************${NC}"
echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
echo " ${PURPLE}${magnifying} Input Parameters${NC}"
echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"

        while getopts "t:d:h:p:s:x:l:c:a:" opt
        do
          case "$opt" in
              t ) INPUT_TOKEN="$OPTARG" ;;
              d ) INPUT_PATH="$OPTARG" ;;
              h ) INPUT_CLUSTER_NAME="$OPTARG" ;;
              p ) INPUT_PWD="$OPTARG" ;;
              s ) INPUT_SC="$OPTARG" ;;
              x ) INPUT_CONSOLE_PREFIX="$OPTARG";;
              l ) INPUT_LDAPPWD="$OPTARG";;
              c ) INPUT_CF_URL="$OPTARG";;
              a ) INPUT_ANSIBLE_INSTALL="$OPTARG";;
          esac
        done



        if [[ $INPUT_TOKEN == "" ]];
        then
            echo "       ${RED}ERROR${NC}: Please provide the Registry Token"
            echo "       USAGE: $0 -t <REGISTRY_TOKEN> -x <OCP_CONSOLE_PREFIX> -s <STORAGE_CLASS> -p <MCM_PASSWORD> -l <LDAP_ADMIN_PASSWORD> [-h <CLUSTER_NAME>] [-d <TEMP_DIRECTORY>] [-c <CLOUDFORMS_URL>] [-a <INSTALL_ANSIBLE (yes)>]"
            exit 1
        else
            echo "       ${GREEN}Token    ${NC}                           $INPUT_TOKEN"
            export ENTITLED_REGISTRY_KEY=$INPUT_TOKEN
        fi




        if [[ $INPUT_PATH == "" ]];
        then
            echo "       ${ORANGE}No Path provided, using${NC}             $TEMP_PATH"
        else
            echo "       ${GREEN}Temp Path${NC}                           $INPUT_PATH"
            export TEMP_PATH=$INPUT_PATH
        fi



        if [[ $INPUT_SC == "" ]];
        then
            echo "       ${RED}ERROR${NC}: Please provide the Storage Class"
            echo "       USAGE: $0 -t <REGISTRY_TOKEN> -x <OCP_CONSOLE_PREFIX> -s <STORAGE_CLASS> -p <MCM_PASSWORD> -l <LDAP_ADMIN_PASSWORD> [-h <CLUSTER_NAME>] [-d <TEMP_DIRECTORY>] [-c <CLOUDFORMS_URL>] [-a <INSTALL_ANSIBLE (yes)>]"
            exit 1
        else
            echo "       ${GREEN}Storage Class    ${NC}                   $INPUT_SC"
            export STORAGE_CLASS_BLOCK=$INPUT_SC
        fi


        if [[ $INPUT_CONSOLE_PREFIX == "" ]];
        then
            echo "    ${RED}ERROR${NC}: Please provide the OCP console prefix (for example console)"
            echo "       USAGE: $0 -t <REGISTRY_TOKEN> -x <OCP_CONSOLE_PREFIX> -s <STORAGE_CLASS> -p <MCM_PASSWORD> -l <LDAP_ADMIN_PASSWORD> [-h <CLUSTER_NAME>] [-d <TEMP_DIRECTORY>] [-c <CLOUDFORMS_URL>] [-a <INSTALL_ANSIBLE (yes)>]"
            exit 1
        else
            echo "       ${GREEN}Console Prefix    ${NC}                  $INPUT_CONSOLE_PREFIX"
            export OCP_CONSOLE_PREFIX=$INPUT_CONSOLE_PREFIX
        fi


        if [[ $INPUT_PWD == "" ]];          
        then
            echo "       ${RED}ERROR${NC}: Please provide the MCM Password"
            echo "       USAGE: $0 -t <REGISTRY_TOKEN> -x <OCP_CONSOLE_PREFIX> -s <STORAGE_CLASS> -p <MCM_PASSWORD> -l <LDAP_ADMIN_PASSWORD> [-h <CLUSTER_NAME>] [-d <TEMP_DIRECTORY>] [-c <CLOUDFORMS_URL>] [-a <INSTALL_ANSIBLE (yes)>]"
            exit 1
        else
            echo "       ${GREEN}Password    ${NC}                        **********"
            export MCM_PWD=$INPUT_PWD
        fi


        if [[ $INPUT_LDAPPWD == "" ]];
        then
            echo "    ${RED}ERROR${NC}: Please provide the LDAP admin password"
            echo "       USAGE: $0 -t <REGISTRY_TOKEN> -x <OCP_CONSOLE_PREFIX> -s <STORAGE_CLASS> -p <MCM_PASSWORD> -l <LDAP_ADMIN_PASSWORD> [-h <CLUSTER_NAME>] [-d <TEMP_DIRECTORY>] [-c <CLOUDFORMS_URL>] [-a <INSTALL_ANSIBLE (yes)>]"
            exit 1
        else
            echo "       ${GREEN}LDAP Password    ${NC}                   **********"
            export LDAP_ADMIN_PASSWORD=$INPUT_LDAPPWD
        fi


        if [[ ($INPUT_CF_URL == "") ]];
        then
            echo "       ${ORANGE}No CloudForms URL provided${NC}          ${CYAN}CloudForms${NC} integration ${NC}will be ${RED}skipped${NC}"
        else
            echo "       ${GREEN}CloudForms URL    ${NC}                  ${CYAN}CloudForms${NC} will be ${GREEN}integrated${NC} with the MCM HUB cluster"
          export CF_URL=$INPUT_CF_URL
        fi

        if [[ $INPUT_ANSIBLE_INSTALL == "yes" ]];
        then
            echo "       ${GREEN}Ansible    ${NC}                         ${CYAN}Ansible Tower${NC} will be ${GREEN}installed${NC} into the MCM HUB cluster"
            OCP_ANSIBLE_INSTALL="yes"
        else
            echo "       ${ORANGE}Ansible not set                     ${NC}${CYAN}Ansible Tower${NC} installation will be ${RED}skipped${NC}. To install Ansible Tower add '-a yes'"
            INPUT_ANSIBLE_INSTALL="no"

        fi


        if [[ ($INPUT_CLUSTER_NAME == "") ]];
        then
            echo "       ${ORANGE}No Cluster Name provided${NC}            ${CYAN}FQDN${NC} will be ${ORANGE}determined${NC} from Kubeconfig in the next step${NC}"
            getClusterFQDN
        else
            echo "       ${GREEN}Cluster :  ${NC}                           $INPUT_CLUSTER_NAME"
            export CLUSTER_NAME=$INPUT_CLUSTER_NAME
        fi




        if [[ ($MASTER_HOST == "0.0.0.0") ]];
        then
            getHosts
        fi
echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${CYAN}***************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "
echo "  "



# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# PRE-Installing CHECKS
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo "${CYAN}***************************************************************************************************************************${NC}"
echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
echo " ${PURPLE}${healthy} Pre-Installing Checks${NC}"
echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"


        checkHelmExecutable

        checkCloudctlExecutable

        dockerRunning

        checkOpenshiftReachable

        checkKubeconfigIsSet

        checkStorageClassExists

        checkDefaultStorageDefined

        checkRegistryCredentials

        getInstallPath

echo "${CYAN}---------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${CYAN}***************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "
echo "  "







echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Installing MultiCloud Manager (MCM) for OpenShift 4.3 ${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

    checkComponentNotInstalled MCM
    if [[ $MUST_INSTALL == "1" ]]; 
    then
        ./2_install_mcm_mutadv_u.sh -t $ENTITLED_REGISTRY_KEY -d $TEMP_PATH -p $MCM_PWD -s $STORAGE_CLASS_BLOCK
        waitForPodsReady kube-system
    else
      echo "     ${RED}${cross} Skipping MultiCloud Manager (MCM) Installation${NC}"
    fi
    echo "  "
    echo "  "
    echo "  "
    echo "  "


    checkComponentNotInstalled MCMREG
    if [[ $MUST_INSTALL == "1" ]]; 
    then
        echo "${GREEN}***************************************************************************************************************************************************${NC}"
        echo "  "
        echo " ${CYAN}${rocket}     Registering MCM-HUB with MCM ${NC}"
        echo "  "
        echo "${GREEN}***************************************************************************************************************************************************${NC}"
        ./7_register_cluster_u.sh -d $TEMP_PATH -x $OCP_CONSOLE_PREFIX -p $MCM_PWD  -n mcm-hub -h "https://icp-console.$CLUSTER_NAME"

    else
        echo "     ${RED}${cross} Skipping Registering MCM-HUB with MCM${NC}"
    fi


    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "










echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Installing Terraform & Service Automation Module (CAM) for OpenShift 4.3${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

    #checkComponentNotInstalled CAM
    MUST_INSTALL=0
    if [[ $MUST_INSTALL == "1" ]]; 
    then
        ./3_install_cam_u.sh -t $ENTITLED_REGISTRY_KEY -d $TEMP_PATH -p $MCM_PWD -x $OCP_CONSOLE_PREFIX -s $STORAGE_CLASS_BLOCK
        #waitForPodsReady service
    else
      echo "     ${RED}${cross} Skipping Terraform & Service Automation Module (CAM) Installation${NC}"
    fi 
  
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "










echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Installing Monitoring Module (APM)for OpenShift 4.3${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

    checkComponentNotInstalled APM
    if [[ $MUST_INSTALL == "1" ]]; 
    then
        ./4_install_apm_u.sh -t $ENTITLED_REGISTRY_KEY -d $TEMP_PATH -p $MCM_PWD -x $OCP_CONSOLE_PREFIX -s $STORAGE_CLASS_BLOCK
        waitForPodsReady kube-system

        echo "${CYAN}  ***************************************************************************************************************************${NC}"
        echo "${CYAN}  ---------------------------------------------------------------------------------------------------------------------------${NC}"
        echo " ${ORANGE}  ${wrench} Registering APM Installation${NC}"
        echo "${CYAN}  ---------------------------------------------------------------------------------------------------------------------------${NC}"
        
        RESULT=$(kubectl exec -n kube-system -t `kubectl get pods -l release=apm-helm -n kube-system | grep "apm-helm-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/oidc_reg.sh" "`echo $(kubectl get secret platform-oidc-credentials -o yaml -n kube-system | grep OAUTH2_CLIENT_REGISTRATION_SECRET: | awk '{print $2}')`")
        RESULT=$(kubectl exec -n kube-system -t `kubectl get pods -l release=apm-helm -n kube-system | grep "apm-helm-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/registerServicePolicy.sh" "`echo $(kubectl get secret apm-helm-cem-service-secret -o yaml -n kube-system | grep cem-service-id: | awk '{print $2}')`" "`cloudctl tokens --access`")
    else
      echo "     ${RED}${cross} Skipping Monitoring Module (APM) Installation${NC}"
      echo "  "
    fi

    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "








echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Installing OPENLDAP${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

    checkComponentNotInstalled LDAP
    if [[ $MUST_INSTALL == "1" ]]; 
    then
        ./8_install_ldap_u.sh -d $TEMP_PATH -x $OCP_CONSOLE_PREFIX -p $LDAP_ADMIN_PASSWORD
        waitForPodsReady default

        echo "${GREEN}   ***************************************************************************************************************************************************${NC}"
        echo "  "
        echo " ${CYAN}   ${rocket} Register OPENLDAP in MCM${NC}"
        echo "  "
        echo "${GREEN}   ***************************************************************************************************************************************************${NC}"

        BASE_DN="dc="$(echo $LDAP_DOMAIN | ${SED} -e "s/\./,dc=/")
        BIND_DN="cn=admin,"$BASE_DN

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo " ${BLUE}Login to PHP LDAP Admin${NC}"
        echo "   GUI is here: http://openldap-admin-default.$CLUSTER_NAME"
        echo ""

        echo ""
        echo ""
        echo " ${BLUE}Configuration for MCM${NC}"
        echo "   Server type: Custom"
        echo "   Base DN: $BASE_DN"
        echo "   Bind DN: $BIND_DN"
        echo "   URL: ldap://openldap.default:389"
        echo "   LDAP Admin Password: $LDAP_ADMIN_PASSWORD"
        echo ""
        echo "   User filter: (&(uid=%v)(objectclass=Person))"
        echo ""
        echo ""
        echo ""


        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} MCM Login${NC}"
        cloudctl login -a ${MCM_SERVER} --skip-ssl-validation -u ${MCM_USER} -p ${MCM_PWD} -n kube-system

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} Creating LDAP Connection${NC}"
        cloudctl iam ldap-create "LDAP" --basedn "$BASE_DN" --server "ldap://openldap.default:389" --binddn "$BIND_DN" --binddn-password "$LDAP_ADMIN_PASSWORD" -t "Custom" --group-filter "(&(cn=%v)(objectclass=groupOfUniqueNames))" --group-id-map "*:cn" --group-member-id-map "groupOfUniqueNames:uniqueMember" --user-filter "(&(uid=%v)(objectclass=Person))" --user-id-map "*:uid"
        TEAM_ID=$(cloudctl iam teams | awk '{ print $1 }')

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} Import Users${NC}"
        cloudctl iam user-import -u demo -f
        cloudctl iam user-import -u dev -f
        cloudctl iam user-import -u test -f
        cloudctl iam user-import -u prod -f

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} Assign Users to Team${NC}"
        cloudctl iam team-add-users 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 Administrator -u demo
        cloudctl iam team-add-users 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 Administrator -u dev
        cloudctl iam team-add-users 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 Administrator -u test
        cloudctl iam team-add-users 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 Administrator -u prod

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} Add LDAP Resource${NC}"
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:iam::::Directory:LDAP

        echo "---------------------------------------------------------------------------------------------------------------------------"
        echo "    ${CYAN}${wrench} Add Namespace Resources${NC}"
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/mcm-mcm-hub:::
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/default:::
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/grpcdemo-app:::
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/grpcdemo-app-ns:::
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/modresort-app:::
        cloudctl iam resource-add 4bb981605258ecc3abe012c4fa0b98a40dc57961e21883f303e3114af1126c83 -r crn:v1:icp:private:k8:mycluster:n/modresort-app-ns:::
    else
      echo "     ${RED}${cross} Skipping LDAP Installation${NC}"
    fi

    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "





echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Installing Ansible Tower${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

    if [[ ! $OCP_ANSIBLE_INSTALL == "y" ]]; 
    then
      #checkComponentNotInstalled ANSIBLE
      MUST_INSTALL=1
      if [[ $MUST_INSTALL == "1" ]]; 
      then
        OCP_ANSIBLE_API=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
        echo $OCP_ANSIBLE_API
        ./5_install_ansible_u.sh -d $TEMP_PATH -p $MCM_PWD -x $OCP_CONSOLE_PREFIX -a $OCP_ANSIBLE_API -s $STORAGE_CLASS_BLOCK
      else
        echo "     ${RED}${cross} Skipping Ansible Tower Installation${NC}"
        echo "  "
      fi
    else
      echo "     ${RED}${cross} Skipping Ansible Tower Installation${NC}"
      echo "  "
    fi

    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "



echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Creating Demo Assets${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "


      echo "   ---------------------------------------------------------------------------------------------------------------------------"
      echo "    ${rocket} Creating ${CYAN}Demo Applications${NC}"
      ./demo/create-apps.sh



      echo "   ---------------------------------------------------------------------------------------------------------------------------"
      echo "    ${rocket} Creating ${CYAN}Demo Policies${NC}" 
      ./demo/create-policies.sh



    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "
    echo "  "





echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo " ${CYAN}${rocket} Integrating external components${NC}"
echo "  "
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "  "
echo "  "
echo "  "

      echo "---------------------------------------------------------------------------------------------------------------------------"
      echo " ${RED}${rocket} Integrating ${CYAN}Terraform & Service Automation Module (CAM)${CYAN}${NC}" 
      checkComponentNotInstalled CAM
      if [[ $MUST_INSTALL == "0" ]]; 
      then
        ./tools/navigation/automation-navigation-updates.sh -a services
      else
        echo "     ${RED}${cross} Skipping Terraform & Service Automation Module (CAM) integration${NC}"
      fi


      echo "---------------------------------------------------------------------------------------------------------------------------"
      echo " ${RED}${rocket} Integrating ${CYAN}CloudForms${CYAN}${NC}" 
      echo "   ${magnifying} Check if ${CYAN}Component${NC} '${ORANGE}CloudForms${NC}' can be integrated"
      if [[ ! ($INPUT_CF_URL == "") ]];
      then
        ./tools/navigation/automation-navigation-updates.sh -c https://52.117.8.177
      else
        echo "     ${RED}${cross} Skipping CloudForms integration${NC}"
      fi


      echo "---------------------------------------------------------------------------------------------------------------------------"
      echo " ${RED}${rocket} Integrating ${CYAN}Ansible Tower${CYAN}${NC}" 
      checkComponentNotInstalled ANSIBLE
      if [[ $MUST_INSTALL == "0" ]]; 
      then
        ./tools/navigation/automation-navigation-updates.sh -t ansible-tower
      else
        echo "     ${RED}${cross} Skipping Ansible Tower integration${NC}"
      fi




echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo " ${GREEN}${healthy} Cloud Pak for Multicloud Management.... DONE${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo " ${GREEN}${explosion}  To remove Components:${NC}"
echo "./demo/delete-apps.sh"
echo "./demo/delete-policies.sh"
echo "$HELM_BIN delete openldap --purge $HELM_TLS"
echo "$HELM_BIN delete $APM_HELM_RELEASE_NAME --purge $HELM_TLS"
echo "$HELM_BIN delete $CAM_HELM_RELEASE_NAME --purge $HELM_TLS"
echo "docker run -t --net=host -e LICENSE=accept -v $INSTALL_PATH/cluster:/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable $ENTITLED_REGISTRY/cp/icp-foundation/mcm-inception:$MCM_VERSION uninstall-with-openshift"
echo "${GREEN}----------------------------------------------------------------------------------------------------------------------------------------------------${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"
echo "${GREEN}***************************************************************************************************************************************************${NC}"


exit 2

