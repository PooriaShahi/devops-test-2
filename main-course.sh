#!/bin/bash
echo "Deploy nginx ingress ..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/baremetal/deploy.yaml

echo "prepare nginx ingress ..."
kubectl delete svc -n ingress-nginx ingress-nginx-controller

echo "Using host network for ingress ..."
kubectl patch deploy -n ingress-nginx ingress-nginx-controller -p '{\"spec\":{\"template\":{\"spec\":{\"hostNetwork\":true}}}}'
  
echo "Getting helm 3 gpgkey ..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null

echo "helm repository ..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
  
echo "install helm 3 ..."
apt update && apt install helm -y
  
echo "Install cert-manager repo ..."
helm repo add jetstack https://charts.jetstack.io
  
echo "Update helm repo ..."
helm repo update
  
echo "install cert-manager ..."
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0 --set installCRDs=true
  
echo "Clone wart project"
git clone https://github.com/PooriaShahi/wart.git

echo "prepare directory for mysql pv ..."
mkdir /mnt/data
chown 777 -R /mnt/data

echo "pull wordpress image ..."
crictl pull wordpress:latest
  
echo "install our application ..."
helm upgrade --install wp-app /root/wart
  
echo "wait for the wp-app pod be running ..."
sleep 10

echo "find wp-app pod ..."
kubectl get pods | grep wp-app | awk '{print $1}'

echo "doing wordpress right ..."
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- ln -s /var/www/html /var/www/html/wordpress
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- chown www-data:www-data -R /var/www/html/wordpress
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- chmod +x wp-cli.phar
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- mv wp-cli.phar /usr/local/bin/wp
kubectl exec -it "$(kubectl get pods | grep wp-app | awk '{print $1}')" -- wp core install --url="$(grep path wart/values.yaml | grep http | awk '{print $2}')" --title=Test --admin_name=admin --admin_password=admin --admin_email=you@domain.com --allow-root 
