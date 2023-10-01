# Aureli (WIP)
A minimal deployment on an EKS Cluster to configure and test many DevOps tools.

Still a work in progress.

## Configured tools and apps.
1. Istio and its supported addons (Kiali, Jaeger, Prometheus, Grafana).
2. Cluster Autoscaler
3. Horizontal Pod Autoscaler
4. Kubecost
5. LitmusChaos
6. Kubeshark
7. Cert Manager
8. Metrics Server
9. EBS CSI Driver
10. CNI
11. ExternalDNS
12. Gateway API (in place of ingress controllers)

## TO-DO
1. Buy a domain name and properly configure the gateways for the services
2. Write all the needed workflows and logic.
3. Implement the needed automated testing (Checkov, Tfsec, Tflint, Falco)
4. Configure Fluentd for log aggregation and integrate it with Falco.
5. Implement Slack channels for notifications
6. Implement RBAC to namespaces by creating users in the cluster.
7. Convert terraform code to custom modules and make the whole deployment use terragrunt.
8. Deploy Docker registry to cluster and make the deployments use it.
9. Implement image verification in registry.
10. Use vault for storing secrets.
11. Use Packer to create node AMIs.
12. Write checkers for the null_resource deployments.
13. Properly expose and configure all the tools and services.
14. Research Karpenter.
