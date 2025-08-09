# KServe Installation Guide for AKS

This guide provides step-by-step instructions to install KServe on your existing AKS cluster for ML model serving capabilities.

## Prerequisites

- **AKS Cluster**: aks-cluster-datamaster in MLProjects resource group
- **Location**: eastus
- **Node Size**: Standard_B2s (2 vCPUs, 4GB RAM) - *Note: Consider scaling up for production workloads*
- **Kubernetes Version**: 1.32.6
- **Tools Required**: Azure CLI, kubectl, Helm 3.x

## Quick Start

### 1. Make scripts executable
```bash
chmod +x install-kserve.sh verify-installation.sh
```

### 2. Install KServe
```bash
./install-kserve.sh
```

### 3. Verify Installation
```bash
./verify-installation.sh
```

## Detailed Installation Steps

### Option A: Automated Installation (Recommended)
```bash
# Run the complete installation script
./install-kserve.sh
```

### Option B: Manual Installation
If you prefer manual control over each step:

1. **Configure kubectl access**
   ```bash
   az aks get-credentials --resource-group MLProjects --name aks-cluster-datamaster
   ```

2. **Install Istio**
   ```bash
   # Install Istio service mesh
   curl -L https://istio.io/downloadIstio | sh -
   cd istio-*
   export PATH=$PWD/bin:$PATH
   istioctl install --skip-confirmation
   kubectl label namespace default istio-injection=enabled
   ```

3. **Install Knative Serving**
   ```bash
   # Install Knative CRDs
   kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-crds.yaml
   
   # Install Knative Serving
   kubectl apply -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-core.yaml
   
   # Install Istio integration
   kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-v1.15.1/net-istio.yaml
   ```

4. **Install cert-manager**
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml
   ```

5. **Install KServe**
   ```bash
   kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.13.1/kserve.yaml
   kubectl apply -f https://github.com/kserve/kserve/releases/download/v0.13.1/kserve-runtimes.yaml
   ```

## Resource Requirements

### Current Setup
- **Node Size**: Standard_B2s (2 vCPUs, 4GB RAM)
- **Suitable for**: Development/testing with small models
- **Limitations**: May struggle with large models or high traffic

### Recommended for Production
- **Node Size**: Standard_D4s_v3 (4 vCPUs, 16GB RAM) or better
- **Node Count**: 2-3 nodes for high availability
- **Command to scale**:
  ```bash
  az aks nodepool scale \
    --resource-group MLProjects \
    --cluster-name aks-cluster-datamaster \
    --name nodepool1 \
    --node-count 2 \
    --node-vm-size Standard_D4s_v3
  ```

## Verification

After installation, verify all components are running:

```bash
./verify-installation.sh
```

Expected output should show all components as "✓ running".

## Testing Your Installation

### Deploy a Sample Model
```bash
# Create a sample sklearn model
kubectl apply -f - <<EOF
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  name: sklearn-iris
spec:
  predictor:
    model:
      modelFormat:
        name: sklearn
      storageUri: "gs://kfserving-examples/models/sklearn/1.0/model"
EOF

# Check status
kubectl get inferenceservice sklearn-iris
```

### Access the Model
```bash
# Get the service URL
kubectl get inferenceservice sklearn-iris -o jsonpath='{.status.url}'
```

## Troubleshooting

### Common Issues

1. **Insufficient Resources**
   - Symptom: Pods stuck in "Pending" state
   - Solution: Scale up your cluster nodes

2. **Istio Gateway Issues**
   - Symptom: Cannot access services externally
   - Solution: Check Istio ingress gateway configuration

3. **Certificate Issues**
   - Symptom: HTTPS endpoints not working
   - Solution: Verify cert-manager is running and certificates are issued

### Debug Commands
```bash
# Check all pods
kubectl get pods --all-namespaces

# Check specific namespace
kubectl get pods -n kserve

# Check logs
kubectl logs -n kserve deployment/kserve-controller-manager

# Check events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

## Uninstallation

To completely remove KServe and all components:

```bash
# Delete KServe
kubectl delete -f https://github.com/kserve/kserve/releases/download/v0.13.1/kserve.yaml
kubectl delete -f https://github.com/kserve/kserve/releases/download/v0.13.1/kserve-runtimes.yaml

# Delete cert-manager
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml

# Delete Knative
kubectl delete -f https://github.com/knative/serving/releases/download/knative-v1.15.2/serving-core.yaml
kubectl delete -f https://github.com/knative/net-istio/releases/download/knative-v1.15.1/net-istio.yaml

# Delete Istio
istioctl uninstall --purge --skip-confirmation
```

## Support

For issues or questions:
- Check the [KServe documentation](https://kserve.github.io/website/)
- Review the troubleshooting section above
- Run the verification script to identify specific issues
