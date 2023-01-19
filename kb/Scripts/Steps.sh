#!/bin/bash
#oidc provider

# read -p  " input a name for cluster: " cluster_name


clustername=${1:-'spogakucluster'}

region=${2:-'ap-southeast-1'}

policyName=${3:-'AWSLoadBalancerControllerIAMPolicyForspogakuCluster'}




eksctl create cluster --name $clustername --version 1.22 --region $region --nodegroup-name standard-workers --node-type t2.small --nodes 3 --nodes-min 3 --nodes-max 3

eksctl utils associate-iam-oidc-provider --cluster=$clustername --approve
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json

#Create a IAM policy:

aws iam get-policy $policyName
if $? == "0"; then
    echo 'Policy already exists with name -  $policyName. So using it'
else
    aws iam create-policy --policy-name $policyName --policy-document file://iam_policy.json
fi     


 
#create a IAM Role:
eksctl create iamserviceaccount \
--cluster=$clustername \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::028791545937:policy/$policyName \
--override-existing-serviceaccounts \
--approve 

#ALB CONTROLLER
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$clustername \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
   -n kube-system

#kubectl get deployment -n kube-system aws-load-balancer-controller 

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=$clustername \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
   -n kube-system

# installation of Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus


# installation of Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana