#!/bin/sh
echo "Welcome to the awx-operator installer"
echo "The script install,remove,check port and password of awx-operator and run with kubernete(k3s) !"
echo "Last step waiting  the run and when finished only press 'ctrl + c' to exit !"
echo "Options(Write only the number):
      1-: Install option,
      2-: Password option(need to the dashboard),
      3-: Check port of awx(dashboard),
      4-: Remove awx-operator"
read input_user

case $input_user in
1)
echo "[Get k3s -----------------]"
curl -sfL https://get.k3s.io | sudo bash -
echo "[Run k3s in /etc/rancher/k3s/k3s.yaml]"
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

echo "[Check node -----------------]"
kubectl get nodes

echo "[Update packages and add install build-essential -----------------]"
sudo apt update -y
sudo apt install -y git build-essential

echo "[Get awx operator -----------------]"
git clone https://github.com/ansible/awx-operator.git

echo "[Move to awx folder -----------------]"
cd awx-operator/

echo "[Create namespace -----------------]"
export NAMESPACE=awx
kubectl create ns ${NAMESPACE}

echo "[Set kubectl config -----------------]"
sudo kubectl config set-context --current --namespace=$NAMESPACE 

echo "[Install curl and jq after set up configuration]"
sudo apt install curl jq
RELEASE_TAG=`curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep tag_name | cut -d '"' -f 4`
echo $RELEASE_TAG
git checkout $RELEASE_TAG

echo "[Add cluster -----------------]"
export NAMESPACE=awx
make deploy

echo "[Check if pods run -----------------]"
kubectl get pods

echo "[Create data persistence -----------------]"
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-data-pvc
  namespace: awx
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
EOF

echo "[Check if run -----------------]"
kubectl get pvc -n awx

echo "[Create and store data in file -----------------]"
echo -n "---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  service_type: nodeport
  projects_persistence: true
  projects_storage_access_mode: ReadWriteOnce
  web_extra_volume_mounts: |
    - name: static-data
      mountPath: /var/lib/projects
  extra_volumes: |
    - name: static-data
      persistentVolumeClaim:
        claimName: static-data-pvc" > awx-deploy.yml

echo "[Create awx -----------------]"
kubectl apply -f awx-deploy.yml

echo "[Finished and check if all is run -----------------]"
watch kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator" ;;
2) 
cd awx-operator/
kubectl get secret awx-admin-password -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' ;;
3) 
cd awx-operator/
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator" ;;
4)
echo "[Remove awx -----------------]"
cd awx-operator/
export NAMESPACE=awx
make undeploy 
cd ..
sudo rm -rf awx-operator/;;
*) echo "Opss.. 404 - option not found !" ;;
esac


