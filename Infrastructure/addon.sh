kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0-rc1" | kubectl apply -f -; }

kubectl label namespace istio-system istio-injection=enabled

for ADDON in kiali jaeger prometheus grafana
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done