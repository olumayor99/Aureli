kubectl label namespace default istio-injection=enabled
cd ../HelmCharts/
helm upgrade --install aureli aureli
kubectl delete pods --all
kubectl delete pods --all -n istio-system
