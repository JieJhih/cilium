#!/usr/bin/env bash
vagrant up
export KUBECONFIG=$PWD/k3s.yaml
kubectl get pods -n kube-system -o wide
kubectl apply -f $PWD/cilium-install.yml
helm install hubble $PWD/hubble/install/kubernetes/hubble --namespace kube-system --set metrics.enabled="{dns:query;ignoreAAAA;destinationContext=pod-short,drop:sourceContext=pod;destinationContext=pod,tcp,flow,port-distribution,icmp,http}" --set ui.enabled=true --set image.tag="v0.5.1"
kubectl create ns metallb-system
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install -f $PWD/configmap.yaml --namespace metallb-system metallb stable/metallb
kubectl patch -n kube-system svc/hubble-ui --patch \
'{"spec": {"type": "LoadBalancer"}}'
kubectl apply -f https://raw.githubusercontent.com/seanmwinn/cilium-k3s-demo/master/example-apps/r2d2.yaml

