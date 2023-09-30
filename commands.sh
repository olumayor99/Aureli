#!/bin/bash

# Add Custer to kubeconfig
aws eks update-kubeconfig --region us-east-1 --name Yolo-EKS

# Deploy metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Manually create horizontal pod autoscaler. IaC is preferred.
kubectl autoscale deployment frontend --cpu-percent=5 --min=1 --max=8

kubectl autoscale deployment backend --cpu-percent=5 --min=1 --max=8

# Test horizontal pod autoscaler
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://frontend-service; done"

kubectl run -i --tty load-generatorrr --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://backend-service; done"

# Download Cluster Autoscaler
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Test Cluster Autoscaler
kubectl scale --replicas=60 deployment frontend

kubectl scale --replicas=60 deployment backend

# Helm
helm create yolo_app

helm template yolo_app

helm lint yolo_app

helm install YoloRelease yolo_app

# Delete A record and TXT record


eksctl create iamserviceaccount \
  --cluster=Aureli-EKS \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::573763289578:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=Aureli-EKS \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled

aws eks describe-addon --cluster-name Aureli-EKS --addon-name vpc-cni --query addon.addonVersion --output text

aws eks create-addon --cluster-name Aureli-EKS --addon-name vpc-cni --addon-version v1.15.0-eksbuild.2 \
    --service-account-role-arn arn:aws:iam::573763289578:role/Aureli-eks_cni_driver_addon_sa

kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0-rc1" | kubectl apply -f -; }
