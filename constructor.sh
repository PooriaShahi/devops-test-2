#!/bin/bash
set -e

# Check root user access to the server
checkUserAccess() {
    if ! ssh -o ConnectTimeout=10 root@"$1" ls; then
       echo "Please fix your root user access to the server"
       exit 1
    fi
}

# Config Kubespray for my environment
configKubespray() {
    cp -rfp ./kubespray/inventory/sample ./kubespray/inventory/myCluster
    CONFIG_FILE=kubespray/inventory/myCluster/hosts.yaml python3 kubespray/contrib/inventory_builder/inventory.py "${1}"

    pip3 install -r kubespray/requirements.txt
    # Using flannel instead of calico
    sed -i -e 's/calico/flannel/g' ./kubespray/inventory/myCluster/group_vars/k8s_cluster/k8s-cluster.yml
}

# Run kubespray for provisioning the cluster
RunKubespray() {
    cd kubespray
    ansible-playbook -i inventory/myCluster/hosts.yaml -u root -b -v cluster.yml
}

# Main function for this script
main() {
    # Read remote server IP
    read -r -p "Enter your server's ip with root user: " serverIP

    # Check root user access to the server
    checkUserAccess "$serverIP"

    # Prepare kubespray
    if [ -d "./kubespray" ]; then
        configKubespray "$serverIP"
    else
        git clone https://github.com/kubernetes-sigs/kubespray.git
        configKubespray "$serverIP"
    fi

    # Run Kubespray installation
    RunKubespray

    scp ./main-course.sh root@"$serverIP":/root
    ssh root@"$serverIP" bash /root/main-course.sh
}

# Execute the bash script
main